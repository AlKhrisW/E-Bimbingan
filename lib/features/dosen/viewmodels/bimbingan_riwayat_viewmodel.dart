import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart'; // Pastikan import model ajuan
import 'package:ebimbingan/data/models/wrapper/helper_log_bimbingan.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

class DosenRiwayatBimbinganViewModel extends ChangeNotifier {
  final LogBimbinganService _logService = LogBimbinganService();
  final UserService _userService = UserService();
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  
  DosenRiwayatBimbinganViewModel();

  // =================================================================
  // STATE
  // =================================================================

  List<HelperLogBimbingan> _riwayatListSource = [];

  LogBimbinganStatus? _activeFilter;
  LogBimbinganStatus? get activeFilter => _activeFilter;

  UserModel? _selectedMahasiswa;
  UserModel? get selectedMahasiswa => _selectedMahasiswa;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearData() {
    _riwayatListSource = [];
    _activeFilter = null;
    _selectedMahasiswa = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // =================================================================
  // GETTERS
  // =================================================================

  List<HelperLogBimbingan> get riwayatList {
    if (_activeFilter == null) {
      return _riwayatListSource;
    }
    return _riwayatListSource
        .where((element) => element.log.status == _activeFilter)
        .toList();
  }

  // =================================================================
  // ACTIONS
  // =================================================================

  void setFilter(LogBimbinganStatus? status) {
    _activeFilter = status;
    notifyListeners();
  }

  Future<void> pilihMahasiswa(String mahasiswaUid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final uid = AuthUtils.currentUid;
    if (uid == null) {
      _errorMessage = "Sesi habis";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final mahasiswa = await _userService.fetchUserByUid(mahasiswaUid);
      _selectedMahasiswa = mahasiswa;

      final List<LogBimbinganModel> logs = await _logService.getRiwayatSpesifik(
        uid, 
        mahasiswaUid,
      );

      final filteredLogs = logs.where((log) => 
          log.status == LogBimbinganStatus.approved || 
          log.status == LogBimbinganStatus.rejected
      ).toList();

      List<HelperLogBimbingan> tempList = [];

      for (var log in filteredLogs) {
        final ajuan = await _ajuanService.getAjuanByUid(log.ajuanUid);

        if (ajuan != null) {
          tempList.add(HelperLogBimbingan(
            log: log,
            mahasiswa: mahasiswa,
            ajuan: ajuan,
          ));
        }
      }

      tempList.sort((a, b) => b.log.waktuPengajuan.compareTo(a.log.waktuPengajuan));
      _riwayatListSource = tempList;

    } catch (e) {
      _errorMessage = "Gagal memuat riwayat: $e";
      _riwayatListSource = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_selectedMahasiswa != null) {
      await pilihMahasiswa(_selectedMahasiswa!.uid);
    }
  }

  // =================================================================
  // NEW: FETCH SINGLE DETAIL (Untuk Notifikasi)
  // =================================================================
  
  /// Mengambil data lengkap (Log + Mahasiswa + Ajuan) berdasarkan ID Log.
  Future<HelperLogBimbingan?> getLogDetail(String logUid) async {
    try {
      // 1. Ambil data Log
      final LogBimbinganModel? log = await _logService.getLogBimbinganByUid(logUid);
      if (log == null) return null;

      // 2. Ambil data Mahasiswa
      final UserModel? mahasiswa = await _userService.fetchUserByUid(log.mahasiswaUid);
      if (mahasiswa == null) return null;

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
}