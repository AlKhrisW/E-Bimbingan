import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';

class DosenMahasiswaViewModel extends ChangeNotifier {
  final UserService _userService;
  final FirebaseAuthService _authService;

  DosenMahasiswaViewModel({
    required UserService userService,
    required FirebaseAuthService authService,
  })  : _userService = userService,
        _authService = authService;

  // =================================================================
  // STATE
  // =================================================================

  List<UserModel> _mahasiswaList = [];
  List<UserModel> get mahasiswaList => _mahasiswaList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // =================================================================
  // LOAD DATA
  // =================================================================

  Future<void> loadMahasiswaBimbingan() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      _errorMessage = "Tidak ada user yang login";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mahasiswaList = await _userService.fetchMahasiswaByDosenUid(currentUser.uid);
    } catch (e) {
      _errorMessage = "Gagal memuat daftar mahasiswa: $e";
      _mahasiswaList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadMahasiswaBimbingan();
}