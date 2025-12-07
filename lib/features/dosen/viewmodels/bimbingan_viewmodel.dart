import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';

// Services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

// Models
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/helper_log_bimbingan.dart';

class DosenBimbinganViewModel extends ChangeNotifier {
  final LogBimbinganService _logService = LogBimbinganService();
  final UserService _userService = UserService();
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();

  late final String dosenUid;

  DosenBimbinganViewModel() {
    dosenUid = AuthUtils.currentUid ?? '';
    if (dosenUid.isNotEmpty) {
      _loadLogPending();
    } else {
      _error = 'User belum login';
      _isLoading = false;
    }
  }

  // =================================================================
  // STATE
  // =================================================================

  List<HelperLogBimbingan> _daftarLog = [];
  List<HelperLogBimbingan> get daftarLog => _daftarLog;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // =================================================================
  // LOAD DATA (FUTURE / ASYNC)
  // =================================================================
  Future<void> _loadLogPending() async {
    // Set loading true setiap kali fungsi ini dipanggil (refresh)
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<LogBimbinganModel> data = await _logService.getPendingLogsByDosenUid(dosenUid);

      if (data.isEmpty) {
        _daftarLog = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // --- LOGIKA MAPPING DATA (Log + User + Ajuan) ---

      // 2. Kumpulkan semua UID unik
      final mhsUids = data.map((e) => e.mahasiswaUid).toSet();
      final ajuanUids = data.map((e) => e.ajuanUid).toSet();

      // 3. Fetch data referensi secara paralel (Tetap pakai Future.wait agar cepat)
      final results = await Future.wait([
        Future.wait(mhsUids.map((uid) => _userService.fetchUserByUid(uid))),
        Future.wait(ajuanUids.map((uid) => _ajuanService.getAjuanByUid(uid))),
      ]);

      final List<UserModel> fetchedUsers = results[0] as List<UserModel>;
      final List<AjuanBimbinganModel?> fetchedAjuans = results[1] as List<AjuanBimbinganModel?>;

      // 4. Buat Dictionary/Map
      final Map<String, UserModel> userMap = {
        for (var user in fetchedUsers) user.uid: user
      };

      final Map<String, AjuanBimbinganModel> ajuanMap = {
        for (var ajuan in fetchedAjuans) 
          if (ajuan != null) ajuan.ajuanUid: ajuan
      };

      // 5. Gabungkan Data
      final List<HelperLogBimbingan> combinedData = [];

      for (var log in data) {
        final mahasiswa = userMap[log.mahasiswaUid];
        final ajuan = ajuanMap[log.ajuanUid];

        if (mahasiswa != null && ajuan != null) {
          combinedData.add(
            HelperLogBimbingan(
              log: log,
              mahasiswa: mahasiswa,
              ajuan: ajuan,
            ),
          );
        }
      }

      // 6. Sorting
      combinedData.sort((a, b) => b.log.waktuPengajuan.compareTo(a.log.waktuPengajuan));

      _daftarLog = combinedData;

    } catch (e) {
      _error = 'Gagal memuat data log: $e';
    } finally {
      // Finally memastikan loading dimatikan baik sukses maupun error
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================================================================
  // ACTION: VERIFIKASI (APPROVE)
  // =================================================================
  Future<void> verifikasiLog(String logUid) async {
    try {
      // 1. Eksekusi Update ke Firebase
      await _logService.updateLogBimbinganStatus(
        logBimbinganUid: logUid,
        status: LogBimbinganStatus.approved,
        catatanDosen: "Disetujui",
      );

      // 2. WAJIB REFRESH MANUAL
      //    Karena pakai Future, UI tidak tahu kalau data berubah.
      //    Kita harus panggil ulang loadLogPending.
      await _loadLogPending();

    } catch (e) {
      _error = 'Gagal verifikasi log: $e';
      notifyListeners();
    }
  }

  // =================================================================
  // ACTION: TOLAK (REJECT)
  // =================================================================
  Future<void> tolakLog(String logUid, String catatan) async {
    if (catatan.trim().isEmpty) {
      _error = 'Catatan penolakan wajib diisi';
      notifyListeners();
      return;
    }

    try {
      // 1. Eksekusi Update ke Firebase
      await _logService.updateLogBimbinganStatus(
        logBimbinganUid: logUid,
        status: LogBimbinganStatus.rejected,
        catatanDosen: catatan.trim(),
      );

      // 2. WAJIB REFRESH MANUAL
      await _loadLogPending();

    } catch (e) {
      _error = 'Gagal menolak log: $e';
      notifyListeners();
    }
  }

  // =================================================================
  // UTILS
  // =================================================================
  /// Method publik untuk dipanggil oleh RefreshIndicator di UI
  Future<void> refresh() async {
    await _loadLogPending();
  }
}