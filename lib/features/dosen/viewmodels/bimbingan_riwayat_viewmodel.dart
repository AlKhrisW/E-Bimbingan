import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';

// models
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/wrapper/helper_log_bimbingan.dart';

// services
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

class DosenRiwayatBimbinganViewModel extends ChangeNotifier {
  final LogBimbinganService _logService = LogBimbinganService();
  final UserService _userService = UserService();
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  
  late final String currentDosenUid;

  DosenRiwayatBimbinganViewModel() {
    currentDosenUid = AuthUtils.currentUid ?? '';
  }

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
  // ACTIONS & METHODS
  // =================================================================

  void setFilter(LogBimbinganStatus? status) {
    _activeFilter = status;
    notifyListeners();
  }

  Future<void> pilihMahasiswa(String mahasiswaUid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil detail mahasiswa
      final mahasiswa = await _userService.fetchUserByUid(mahasiswaUid);
      _selectedMahasiswa = mahasiswa;

      // 2. Ambil Riwayat Log
      final List<LogBimbinganModel> logs = await _logService.getRiwayatSpesifik(
        currentDosenUid, 
        mahasiswaUid,
      );

      // 3. Filter status (Approved & Rejected only)
      final filteredLogs = logs.where((log) => 
          log.status == LogBimbinganStatus.approved || 
          log.status == LogBimbinganStatus.rejected
      ).toList();

      // 4. Mapping data ke Helper (Log + Mahasiswa + Ajuan)
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

      // 5. Sorting (Terbaru di atas)
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

  // =================================================================
  // UTILS
  // =================================================================

  Future<void> refresh() async {
    if (_selectedMahasiswa != null) {
      await pilihMahasiswa(_selectedMahasiswa!.uid);
    }
  }
}