import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';

// models
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';

// services
import 'package:ebimbingan/data/services/logbook_harian_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';

class DosenLogbookHarianViewModel extends ChangeNotifier {
  final LogbookHarianService _logbookHarianService = LogbookHarianService();
  final UserService _userService = UserService();
  
  late final String currentDosenUid;

  DosenLogbookHarianViewModel() {
    currentDosenUid = AuthUtils.currentUid ?? '';
  }

  // =================================================================
  // STATE
  // =================================================================

  // List utama dari database (Source Data)
  List<LogbookHarianModel> _logbookListSource = [];

  // Filter aktif (null = Semua, Verified, Draft)
  LogbookStatus? _activeFilter;
  LogbookStatus? get activeFilter => _activeFilter;

  // Data detail mahasiswa yang sedang dilihat
  UserModel? _selectedMahasiswa;
  UserModel? get selectedMahasiswa => _selectedMahasiswa;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // =================================================================
  // GETTERS (UI LOGIC)
  // =================================================================

  /// Mengambil list yang sudah difilter sesuai bubble pilihan user
  List<LogbookHarianModel> get logbooks {
    if (_activeFilter == null) {
      return _logbookListSource;
    }
    return _logbookListSource
        .where((element) => element.status == _activeFilter)
        .toList();
  }

  // =================================================================
  // ACTIONS & METHODS
  // =================================================================

  void setFilter(LogbookStatus? status) {
    _activeFilter = status;
    notifyListeners();
  }

  /// Dipanggil ketika dosen memilih salah satu mahasiswa dari daftar
  Future<void> pilihMahasiswa(String mahasiswaUid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil detail mahasiswa
      final mahasiswa = await _userService.fetchUserByUid(mahasiswaUid);
      _selectedMahasiswa = mahasiswa;

      // 2. Ambil Logbook Harian (FUTURE)
      final List<LogbookHarianModel> data = await _logbookHarianService.getLogbook(
        mahasiswaUid, 
        currentDosenUid
      );

      // 3. Simpan ke source list
      _logbookListSource = data;

    } catch (e) {
      _errorMessage = "Gagal memuat logbook: $e";
      _logbookListSource = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================================================================
  // UTILS
  // =================================================================

  /// Refresh manual
  Future<void> refresh() async {
    if (_selectedMahasiswa != null) {
      await pilihMahasiswa(_selectedMahasiswa!.uid);
    }
  }
}