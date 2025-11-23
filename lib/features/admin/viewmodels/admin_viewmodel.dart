// lib/features/viewmodels/admin_viewmodel.dart

import 'package:flutter/material.dart';
import 'dart:async';

import '../../../data/models/user_model.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../auth/views/login_page.dart';

class AdminViewModel with ChangeNotifier {
  // --- SERVICE LAYER ---
  final UserService _userService = UserService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  // --- STATE ---
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setMessage({String? error, String? success}) {
    _errorMessage = error;
    _successMessage = success;
    notifyListeners();
  }

  // ----------------------------------------------------------------------
  // FETCH DATA
  // ----------------------------------------------------------------------

  // ambil semua user
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      return _userService.fetchAllUsers();
    } catch (e) {
      throw 'Gagal memuat semua data pengguna: $e';
    }
  }

  /// Ambil daftar dosen (untuk dropdown mahasiswa)
  Future<List<UserModel>> fetchDosenList() async {
    try {
      return _userService.fetchDosenList();
    } catch (e) {
      throw 'Gagal memuat daftar dosen: $e';
    }
  }

  Future<void> logout() async {
  // kalau mau hapus token, tambahkan di sini
  await Future.delayed(const Duration(milliseconds: 500));
}

Future<void> handleLogout(BuildContext context) async {
  await logout();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}

  

  // ----------------------------------------------------------------------
  // REGISTER USER UNIVERSAL
  // ----------------------------------------------------------------------

  Future<bool> registerUserUniversal({
    required String email,
    required String name,
    required String role,
    required String programStudi,
    required String phoneNumber,
    // Mahasiswa Specific
    String? nim,
    String? placement,
    DateTime? startDate,
    String? dosenUid,
    // Dosen Specific
    String? nip,
    String? jabatan,
  }) async {
    _setLoading(true);
    _setMessage(error: null, success: null);

    try {
      await _authService.registerUser(
        email: email,
        password: "password", // password default
        name: name,
        role: role,
        programStudi: programStudi,
        phoneNumber: phoneNumber,
        nim: nim,
        placement: placement,
        startDate: startDate,
        dosenUid: dosenUid,
        nip: nip,
        jabatan: jabatan,
      );

      _setMessage(
        success: "Akun $name berhasil didaftarkan! Password default: password.",
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setMessage(error: e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ----------------------------------------------------------------------
  // UPDATE USER UNIVERSAL
  // ----------------------------------------------------------------------

  Future<bool> updateUserUniversal({
    required String uid,
    required String email,
    required String name,
    required String role,
    required String programStudi,
    required String phoneNumber,
    // Mahasiswa Specific
    String? nim,
    String? placement,
    DateTime? startDate,
    String? dosenUid,
    // Dosen Specific
    String? nip,
    String? jabatan,
  }) async {
    _setLoading(true);
    _setMessage(error: null, success: null);

    try {
      final updatedUser = UserModel(
        uid: uid,
        email: email,
        name: name,
        role: role,
        programStudi: programStudi,
        phoneNumber: phoneNumber,
        nim: nim,
        placement: placement,
        startDate: startDate,
        dosenUid: dosenUid,
        nip: nip,
        jabatan: jabatan,
      );

      await _userService.updateUserMetadata(updatedUser);

      _setMessage(success: "Data $name berhasil diperbarui!");
      _setLoading(false);
      return true;
    } catch (e) {
      _setMessage(error: "Gagal memperbarui data: $e");
      _setLoading(false);
      return false;
    }
  }

  // ----------------------------------------------------------------------
  // DELETE USER
  // ----------------------------------------------------------------------

  Future<bool> deleteUser(String uid) async {
    _setMessage(error: null, success: null);

    try {
      await _authService.deleteUser(uid);
      _setMessage(success: "Pengguna berhasil dihapus!");
      return true;
    } catch (e) {
      _setMessage(error: "Gagal menghapus pengguna: $e");
      return false;
    }
  }

  // ----------------------------------------------------------------------
  // UPDATE USER (model langsung)
  // ----------------------------------------------------------------------

  Future<bool> updateUserData(UserModel user) async {
    _setMessage(error: null, success: null);

    try {
      await _userService.updateUserMetadata(user);
      _setMessage(success: "Data pengguna berhasil diperbarui!");
      return true;
    } catch (e) {
      _setMessage(error: "Gagal memperbarui data: $e");
      return false;
    }
  }
}
