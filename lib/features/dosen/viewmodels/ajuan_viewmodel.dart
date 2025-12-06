import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';

// services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

// models
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/helper_ajuan_bimbingan.dart';

class DosenAjuanViewModel extends ChangeNotifier {
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final LogBimbinganService _logService = LogBimbinganService();
  final UserService _userService = UserService();

  late final String dosenUid;

  DosenAjuanViewModel() {
    dosenUid = AuthUtils.currentUid ?? '';
    if (dosenUid.isNotEmpty) {
      _loadAjuanProses();
    } else {
      _error = 'User belum login';
      _isLoading = false;
    }
  }

  // =================================================================
  // STATE
  // =================================================================

  List<AjuanWithMahasiswa> _daftarAjuan = [];
  List<AjuanWithMahasiswa> get daftarAjuan => _daftarAjuan;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // =================================================================
  // LOAD DATA (FUTURE)
  // =================================================================
  Future<void> _loadAjuanProses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Ambil data ajuan (Future)
      final List<AjuanBimbinganModel> data = await _ajuanService.getAjuanByDosenUid(dosenUid);

      if (data.isEmpty) {
        _daftarAjuan = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Kumpulkan UID Mahasiswa unik
      final mahasiswaUids = data.map((e) => e.mahasiswaUid).toSet();

      // 3. Fetch data user secara paralel
      final List<UserModel> fetchedUsers = await Future.wait(
        mahasiswaUids.map((uid) => _userService.fetchUserByUid(uid)),
      );

      // 4. Buat Map User
      final Map<String, UserModel> userMap = {
        for (var user in fetchedUsers) user.uid: user
      };

      // 5. Gabungkan data Ajuan dengan User
      final List<AjuanWithMahasiswa> combinedData = [];

      for (var ajuan in data) {
        final mahasiswa = userMap[ajuan.mahasiswaUid];
        
        if (mahasiswa != null) {
          combinedData.add(
            AjuanWithMahasiswa(
              ajuan: ajuan,
              mahasiswa: mahasiswa,
            ),
          );
        }
      }

      // 6. Sorting (Terbaru di atas)
      combinedData.sort((a, b) => b.ajuan.waktuDiajukan.compareTo(a.ajuan.waktuDiajukan));

      _daftarAjuan = combinedData;

    } catch (e) {
      _error = 'Gagal memproses data ajuan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================================================================
  // ACTION: SETUJUI
  // =================================================================
  Future<void> setujui(String ajuanUid) async {
    try {
      // Cari item di list lokal
      final itemTarget = _daftarAjuan.firstWhere(
        (element) => element.ajuan.ajuanUid == ajuanUid,
        orElse: () => throw Exception("Data tidak ditemukan"),
      );

      // 1. Generate ID Log baru
      final String newLogUid = FirebaseFirestore.instance.collection('log_bimbingan').doc().id;

      // 2. Buat objek Log Bimbingan
      final newLog = LogBimbinganModel(
        logBimbinganUid: newLogUid,
        ajuanUid: ajuanUid,
        mahasiswaUid: itemTarget.ajuan.mahasiswaUid, // Akses via objek
        dosenUid: dosenUid,
        ringkasanHasil: '',
        status: LogBimbinganStatus.draft,
        waktuPengajuan: DateTime.now(),
        catatanDosen: null,
        lampiranUrl: null,
      );

      // 3. Update Status Ajuan
      await _ajuanService.updateAjuanStatus(
        ajuanUid: ajuanUid,
        status: AjuanStatus.disetujui,
      );

      // 4. Simpan Log
      await _logService.saveLogBimbingan(newLog);

      // 5. Refresh
      await _loadAjuanProses();

    } catch (e) {
      _error = 'Gagal menyetujui ajuan: $e';
      notifyListeners();
    }
  }

  // =================================================================
  // ACTION: TOLAK
  // =================================================================
  Future<void> tolak(String ajuanUid, String keterangan) async {
    if (keterangan.trim().isEmpty) {
      _error = 'Keterangan penolakan wajib diisi';
      notifyListeners();
      return;
    }

    try {
      await _ajuanService.updateAjuanStatus(
        ajuanUid: ajuanUid,
        status: AjuanStatus.ditolak,
        keterangan: keterangan.trim(),
      );

      await _loadAjuanProses();
      
    } catch (e) {
      _error = 'Gagal menolak ajuan: $e';
      notifyListeners();
    }
  }

  // =================================================================
  // UTILS
  // =================================================================
  Future<void> refresh() async {
    await _loadAjuanProses();
  }
}