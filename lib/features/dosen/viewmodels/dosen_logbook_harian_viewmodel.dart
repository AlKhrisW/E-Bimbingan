// lib/viewmodels/dosen_logbook_harian_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/logbook_harian_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';

class DosenLogbookHarianViewModel extends ChangeNotifier {
  final LogbookHarianService logbookHarianService;
  final UserService userService;

  DosenLogbookHarianViewModel({
    required this.logbookHarianService,
    required this.userService,
  });

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
      // 1. Ambil detail mahasiswa
      final mahasiswa = await userService.fetchUserByUid(mahasiswaUid);
      _selectedMahasiswa = mahasiswa;

      // 2. Dengarkan semua logbook harian milik mahasiswa ini (REAL-TIME)
      _subscription = logbookHarianService
          .getLogbookByMahasiswaUid(mahasiswaUid)
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

  /// Refresh manual (bisa dipakai untuk pull-to-refresh)
  void refresh() {
    if (_selectedMahasiswa != null) {
      pilihMahasiswa(_selectedMahasiswa!.uid);
    }
  }
}