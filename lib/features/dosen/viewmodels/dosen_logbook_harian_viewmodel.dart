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

  // Data
  List<LogbookHarianModel> _logbooks = [];
  List<LogbookHarianModel> get logbooks => _logbooks;

  UserModel? _selectedMahasiswa;
  UserModel? get selectedMahasiswa => _selectedMahasiswa;

  // UI State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _subscription;

  /// Dipanggil ketika dosen memilih salah satu mahasiswa dari daftar
  Future<void> pilihMahasiswa(String mahasiswaUid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Batalkan stream sebelumnya
    await _subscription?.cancel();

    try {
      // 1. Ambil detail mahasiswa menggunakan internal service
      final mahasiswa = await _userService.fetchUserByUid(mahasiswaUid);
      _selectedMahasiswa = mahasiswa;

      // 2. Dengarkan logbook harian (REAL-TIME)
      _subscription = _logbookHarianService
          .getLogbook(mahasiswaUid, currentDosenUid)
          .listen((data) {
        _logbooks = data;
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _errorMessage = "Gagal memuat logbook: $e";
        _logbooks = [];
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = "Gagal memuat data mahasiswa: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Bersihkan saat tidak dipakai lagi
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Refresh manual
  void refresh() {
    if (_selectedMahasiswa != null) {
      pilihMahasiswa(_selectedMahasiswa!.uid);
    }
  }
}