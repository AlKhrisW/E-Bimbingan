import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/wrapper/helper_log_harian.dart';
import 'package:ebimbingan/data/services/logbook_harian_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';

class DosenLogbookHarianViewModel extends ChangeNotifier {
  final LogbookHarianService _logbookHarianService = LogbookHarianService();
  final UserService _userService = UserService();
  
  DosenLogbookHarianViewModel();

  // =================================================================
  // STATE
  // =================================================================

  List<HelperLogbookHarian> _logbookListSource = [];

  LogbookStatus? _activeFilter;
  LogbookStatus? get activeFilter => _activeFilter;

  UserModel? _selectedMahasiswa;
  UserModel? get selectedMahasiswa => _selectedMahasiswa;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // =================================================================
  // GETTERS
  // =================================================================

  List<HelperLogbookHarian> get logbooks {
    if (_activeFilter == null) {
      return _logbookListSource;
    }
    return _logbookListSource
        .where((element) => element.logbook.status == _activeFilter)
        .toList();
  }

  // =================================================================
  // ACTIONS
  // =================================================================

  void setFilter(LogbookStatus? status) {
    _activeFilter = status;
    notifyListeners();
  }

  Future<void> pilihMahasiswa(String mahasiswaUid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final uid = AuthUtils.currentUid;
    if (uid == null) {
      _errorMessage = "Sesi habis, silakan login ulang";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final mahasiswa = await _userService.fetchUserByUid(mahasiswaUid);
      _selectedMahasiswa = mahasiswa;

      final List<LogbookHarianModel> data = await _logbookHarianService.getLogbook(
        mahasiswaUid, 
        uid 
      );

        final List<HelperLogbookHarian> wrappedList = data.map((item) {
          return HelperLogbookHarian(
            logbook: item,
            mahasiswa: mahasiswa,
          );
        }).toList();

        _logbookListSource = wrappedList;

    } catch (e) {
      _errorMessage = "Gagal memuat logbook: $e";
      _logbookListSource = [];
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
  
  /// Mengambil data lengkap (Logbook + Mahasiswa) berdasarkan ID Logbook.
  Future<HelperLogbookHarian?> getLogbookDetail(String logbookId) async {
    try {
      // 1. Ambil Logbook by ID
      // Asumsi: Service mengembalikan List, kita ambil yang pertama
      final LogbookHarianModel? logbookItem = await _logbookHarianService.getLogbookById(logbookId);
      
      if (logbookItem == null) return null;

      // 2. Ambil User (Mahasiswa)
      final UserModel? mahasiswa = await _userService.fetchUserByUid(logbookItem.mahasiswaUid);

      if (mahasiswa == null) return null;

      // 3. Return Wrapper
      return HelperLogbookHarian(
        logbook: logbookItem,
        mahasiswa: mahasiswa,
      );
    } catch (e) {
      debugPrint("Error fetching logbook detail: $e");
      return null;
    }
  }
}