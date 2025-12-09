// lib/features/auth/viewmodels/auth_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../data/models/user_model.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/user_service.dart';
class AuthViewModel with ChangeNotifier {
  // --- dependency injection ---
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final UserService _userService;

  bool _isLoading = false;
  String? _errorMessage;

  // 1. konstruktor publik
  AuthViewModel()
    : _authService = FirebaseAuthService(),
      _firestoreService = FirestoreService(),
      _userService = UserService();

  // 2. konstruktor internal/named (untuk unit testing)
  @visibleForTesting
  AuthViewModel.internal({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
    required UserService userService,
  }) : _authService = authService,
       _firestoreService = firestoreService,
       _userService = userService;

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

        _saveFcmToken(user.uid);

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

  // Helper method untuk menyimpan token (Private)
  Future<void> _saveFcmToken(String uid) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _userService.saveDeviceToken(uid, token);
      }
    } catch (e) {
      print("Warning: Gagal menyimpan token FCM di ViewModel: $e");
    }
  }

  // Logic Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        await _userService.removeDeviceToken(currentUser.uid);
      }

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