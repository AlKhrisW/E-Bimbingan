import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/logbook_harian_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';

class DosenLogbookHarianViewModel extends ChangeNotifier {
  final LogbookHarianService _logbookService;
  final UserService _userService;

  DosenLogbookHarianViewModel({
    required LogbookHarianService logbookHarianService,
    required UserService userService,
  })  : _logbookService = logbookHarianService,
       _userService = userService;

  // Data State
  List<LogbookHarianModel> _logbookList = [];
  List<LogbookHarianModel> get logbookList => _logbookList;

  // Mahasiswa detail
  UserModel? _mahasiswa;
  UserModel? get mahasiswa => _mahasiswa;

  // UI State
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Untuk mengelola langganan stream agar tidak terjadi memory leak
  StreamSubscription<List<LogbookHarianModel>>? _logbookSubscription;
  // Tidak perlu subscription untuk mahasiswa (single fetch)

  /// Memuat dan mendengarkan (listen) perubahan logbook harian dari Firestore.
  /// Data akan diperbarui secara otomatis ketika ada perubahan di backend,
  /// termasuk saat status (draft, verified, rejected) berubah.
  void loadLogbooks(String mahasiswaUid) {
    // 1. Reset State dan Set Loading
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 2. Batalkan subscription sebelumnya (jika ada)
    _logbookSubscription?.cancel();

    try {
      // 2a. Fetch mahasiswa detail (single fetch) - non blocking for stream
      _userService.fetchUserByUid(mahasiswaUid).then((u) {
        _mahasiswa = u;
        notifyListeners();
      }).catchError((e) {
        // jika gagal ambil mahasiswa, tetap lanjut ke stream tapi simpan error message ringan
        _errorMessage = 'Gagal memuat data mahasiswa: $e';
        notifyListeners();
      });

      // 3. Dapatkan Stream dari service dan mulai mendengarkannya
      _logbookSubscription = _logbookService
          .getLogbookByMahasiswaUid(mahasiswaUid) // Menggunakan Stream dari service
          .listen((logbooks) {
        
        // 4. Update data dan stop loading
        _logbookList = logbooks;
        _isLoading = false; 
        notifyListeners();

      }, onError: (error) {
        // Handle error saat stream gagal
        _errorMessage = "Gagal memuat logbook: $error";
        _logbookList = [];
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = "Terjadi kesalahan: $e";
      _logbookList = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Wajib: Membatalkan subscription saat ViewModel tidak lagi digunakan
  @override
  void dispose() {
    _logbookSubscription?.cancel();
    super.dispose();
  }
}