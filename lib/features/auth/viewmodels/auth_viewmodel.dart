// lib/features/auth/viewmodels/auth_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../data/services/firestore_service.dart';

class AuthViewModel with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _isLoading = false;
  String? _errorMessage;

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
  Future<UserModel?> login({required String email, required String password}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final user = await _authService.signInUser(email: email, password: password);
      
      if (user != null) {
        // Ambil data metadata (role) dari Firestore
        final UserModel userModel = await _firestoreService.getUserData(user.uid);
        _setLoading(false);
        return userModel;
      }
    } catch (e) {
      final String errorMsg = e.toString().contains('Data pengguna tidak ditemukan')
          ? 'Akun tidak terdaftar di database. Silakan hubungi Admin.'
          : e.toString();
          
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