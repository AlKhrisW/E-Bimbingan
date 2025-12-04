import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../data/services/firestore_service.dart';

class AuthViewModel with ChangeNotifier {
  // --- dependency injection ---
  // dependensi sekarang final dan wajib diinisialisasi
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  bool _isLoading = false;
  String? _errorMessage;

  // 1. konstruktor publik (untuk penggunaan provider normal)
  AuthViewModel()
    : _authService = FirebaseAuthService(),
      _firestoreService = FirestoreService();

  // 2. konstruktor internal/named (untuk unit testing/injeksi mock)
  @visibleForTesting
  AuthViewModel.internal({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  }) : _authService = authService,
       _firestoreService = firestoreService;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Logic Login: Mendapatkan UserModel dan menentukan tujuan (role)
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    // VALIDASI INPUT
    if (email.isEmpty) {
      _setErrorMessage("Email tidak boleh kosong");
      return null;
    }

    if (password.isEmpty) {
      _setErrorMessage("Password tidak boleh kosong");
      return null;
    }

    if (password.length < 6) {
      _setErrorMessage("Password minimal 6 karakter");
      return null;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final user = await _authService.signInUser(
        email: email,
        password: password,
      );

      if (user != null) {
        final userModel = await _firestoreService.getUserData(user.uid);

        _setLoading(false);
        return userModel;
      }
    } catch (e) {
      final String errorMsg =
          e.toString().contains('Data pengguna tidak ditemukan')
          ? 'Akun tidak terdaftar di database. Silakan hubungi Admin.'
          : e.toString().replaceFirst('Exception: ', '');

      _setErrorMessage(errorMsg);
      print('LOGIN FAILURE: $errorMsg');
    }

    _setLoading(false);
    return null;
  }

  // Logic Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } catch (e) {
      print("Error saat logout: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Logic Reset Password
  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _authService.resetPassword(email: email);
      _setLoading(false);
      return true;
    } on Exception catch (e) {
      _setErrorMessage('Gagal mengirim link reset password: $e');
      _setLoading(false);
      return false;
    }
  }
}
