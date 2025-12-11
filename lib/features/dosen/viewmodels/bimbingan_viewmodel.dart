import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Utils
import 'package:ebimbingan/core/utils/auth_utils.dart';

// Services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/data/services/notification_service.dart';

// Models
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/dosen_helper_mingguan.dart';

class DosenBimbinganViewModel extends ChangeNotifier {
  final LogBimbinganService _logService = LogBimbinganService();
  final UserService _userService = UserService();
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final NotificationService _notifService = NotificationService();

  DosenBimbinganViewModel();

  // =================================================================
  // STATE
  // =================================================================

  List<HelperLogBimbingan> _daftarLog = [];
  List<HelperLogBimbingan> get daftarLog => _daftarLog;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearData() {
    _daftarLog = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // =================================================================
  // LOAD DATA UTAMA (List Pending)
  // =================================================================

  Future<void> _loadLogPending() async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    final authUtils = AuthUtils();
    final uid = authUtils.currentUid;
    if (uid == null) {
      _error = 'User belum login';
      _isLoading = false;
      _safeNotifyListeners();
      return;
    }

    try {
      final List<LogBimbinganModel> data = await _logService.getPendingLogsByDosenUid(uid);

      if (data.isEmpty) {
        _daftarLog = [];
        _isLoading = false;
        _safeNotifyListeners();
        return;
      }

      final mhsUids = data.map((e) => e.mahasiswaUid).toSet();
      final ajuanUids = data.map((e) => e.ajuanUid).toSet();

      final results = await Future.wait([
        Future.wait(mhsUids.map((uid) => _userService.fetchUserByUid(uid))),
        Future.wait(ajuanUids.map((uid) => _ajuanService.getAjuanByUid(uid))),
      ]);

      final List<UserModel> fetchedUsers = results[0] as List<UserModel>;
      final List<AjuanBimbinganModel?> fetchedAjuans = results[1] as List<AjuanBimbinganModel?>;

      final Map<String, UserModel> userMap = {
        for (var user in fetchedUsers) user.uid: user
      };

      final Map<String, AjuanBimbinganModel> ajuanMap = {
        for (var ajuan in fetchedAjuans) 
          if (ajuan != null) ajuan.ajuanUid: ajuan
      };

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

      combinedData.sort((a, b) => b.log.waktuPengajuan.compareTo(a.log.waktuPengajuan));
      _daftarLog = combinedData;

    } catch (e) {
      _error = 'Gagal memuat daftar log bimbingan: $e';
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // =================================================================
  // NEW: FETCH SINGLE LOG DETAIL (Untuk Notifikasi)
  // =================================================================
  
  /// Mengambil data lengkap (Log + Mahasiswa + Ajuan) berdasarkan ID Log.
  Future<HelperLogBimbingan?> getLogDetail(String logUid) async {
    try {
      // 1. Ambil data Log
      final LogBimbinganModel? log = await _logService.getLogBimbinganByUid(logUid);
      if (log == null) return null;

      // 2. Ambil data Mahasiswa
      final UserModel mahasiswa = await _userService.fetchUserByUid(log.mahasiswaUid);

      // 3. Ambil data Ajuan Terkait
      final AjuanBimbinganModel? ajuan = await _ajuanService.getAjuanByUid(log.ajuanUid);
      if (ajuan == null) return null;

      // 4. Return wrapper
      return HelperLogBimbingan(
        log: log,
        mahasiswa: mahasiswa,
        ajuan: ajuan,
      );
    } catch (e) {
      debugPrint("Error fetching log detail: $e");
      return null;
    }
  }

  // =================================================================
  // ACTIONS
  // =================================================================

  Future<void> verifikasiLog(String logUid) async {
    try {
      // Logic pencarian data (Safe check jika item tidak ada di list)
      HelperLogBimbingan? targetItem;
      try {
        targetItem = _daftarLog.firstWhere((e) => e.log.logBimbinganUid == logUid);
      } catch (_) {
        targetItem = await getLogDetail(logUid);
      }

      if (targetItem == null) throw Exception("Data log tidak ditemukan");

      await _logService.updateStatusVerifikasi(
        logBimbinganUid: logUid,
        status: LogBimbinganStatus.approved,
        catatanDosen: "",
      );

      await _notifService.sendNotification(
        recipientUid: targetItem.log.mahasiswaUid,
        title: "Log Bimbingan Diverifikasi",
        body: "Log tanggal ${DateFormat('dd MMM').format(targetItem.log.waktuPengajuan)} telah disetujui.",
        type: "log_status",
        relatedId: logUid,
      );

      // Refresh list jika ada
      if (_daftarLog.isNotEmpty) {
        await _loadLogPending();
      }
    } catch (e) {
      _error = 'Gagal verifikasi log: $e';
      _safeNotifyListeners();
    }
  }

  Future<void> tolakLog(String logUid, String catatan) async {
    if (catatan.trim().isEmpty) {
      _error = 'Catatan penolakan wajib diisi';
      _safeNotifyListeners();
      return;
    }

    try {
      HelperLogBimbingan? targetItem;
      try {
        targetItem = _daftarLog.firstWhere((e) => e.log.logBimbinganUid == logUid);
      } catch (_) {
        targetItem = await getLogDetail(logUid);
      }

      if (targetItem == null) throw Exception("Data log tidak ditemukan");

      await _logService.updateStatusVerifikasi(
        logBimbinganUid: logUid,
        status: LogBimbinganStatus.rejected,
        catatanDosen: catatan.trim(),
      );

      await _notifService.sendNotification(
        recipientUid: targetItem.log.mahasiswaUid,
        title: "Log Bimbingan Perlu Revisi",
        body: "Catatan Dosen: $catatan",
        type: "log_status",
        relatedId: logUid,
      );

      if (_daftarLog.isNotEmpty) {
        await _loadLogPending();
      }
    } catch (e) {
      _error = 'Gagal menolak log: $e';
      _safeNotifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadLogPending();
  }
}