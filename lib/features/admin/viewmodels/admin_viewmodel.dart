// lib/features/viewmodels/admin_viewmodel.dart

import 'package:flutter/material.dart';
import 'dart:async';
// Import dependencies dari layer data
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/firebase_auth_service.dart';

class AdminViewModel with ChangeNotifier {
  // --- LAYER SERVICE ---
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  // --- STATE MANAGEMENT ---
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage; // Wajib ada untuk feedback UI

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

  // --- FUNGSI UTAMA: Mengambil semua User (untuk User Screen) ---
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      return _firestoreService.fetchAllUsers();
    } catch (e) {
      throw 'Gagal memuat semua data pengguna: $e';
    }
  }

  /// Mengambil daftar Dosen (untuk Dropdown Registrasi Mhs)
  Future<List<UserModel>> fetchDosenList() async {
    try {
      return _firestoreService.fetchDosenList();
    } catch (e) {
      throw 'Gagal memuat daftar dosen: $e';
    }
  }

  // --- LOGIC PENDAFTARAN UNIVERSAL (TAMBAH PARAMETER NIM) ---
Future<bool> registerUserUniversal({
  required String email,
  required String name,
  required String role,
  required String programStudi,
  required String phoneNumber,
  // Mahasiswa Specific
  String? nim,           // ← TAMBAHKAN INI
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
      password: 'password',
      name: name,
      role: role,
      programStudi: programStudi,
      phoneNumber: phoneNumber,
      nim: nim,           // ← TAMBAHKAN INI
      placement: placement,
      startDate: startDate,
      dosenUid: dosenUid,
      nip: nip,
      jabatan: jabatan,
    );

    _setMessage(
      success: 'Akun $name berhasil didaftarkan! Password default: password.',
    );
    await Future.delayed(const Duration(milliseconds: 500));

    _setLoading(false);
    return true;
  } catch (e) {
    _setMessage(error: e.toString());
    _setLoading(false);
    return false;
  }
}

// --- LOGIC UPDATE USER UNIVERSAL (TAMBAH PARAMETER NIM) ---
Future<bool> updateUserUniversal({
  required String uid,
  required String email,
  required String name,
  required String role,
  required String programStudi,
  required String phoneNumber,
  // Mahasiswa Specific
  String? nim,           // ← TAMBAHKAN INI
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
      nim: nim,           // ← TAMBAHKAN INI
      placement: placement,
      startDate: startDate,
      dosenUid: dosenUid,
      nip: nip,
      jabatan: jabatan,
    );

    await _firestoreService.updateUserMetadata(updatedUser);

    _setMessage(success: 'Data $name berhasil diperbarui!');
    _setLoading(false);
    return true;
  } catch (e) {
    _setMessage(error: 'Gagal memperbarui data: $e');
    _setLoading(false);
    return false;
  }
}
  // Logic delete user (dipanggil dari UI)
  Future<bool> deleteUser(String uid) async {
    _setMessage(error: null, success: null);
    try {
      // Panggil Service Layer untuk menghapus (Service Layer akan handle Firestore/Auth complexity)
      await _authService.deleteUser(uid);
      _setMessage(success: 'Pengguna berhasil dihapus!');
      return true;
    } catch (e) {
      _setMessage(error: 'Gagal menghapus pengguna: $e');
      return false;
    }
  }

  // Logic update user (dipanggil dari ui)
  Future<bool> updateUserData(UserModel user) async {
    _setMessage(error: null, success: null);
    try {
      await _firestoreService.updateUserMetadata(user);
      _setMessage(success: 'Data pengguna berhasil diperbarui!');
      return true;
    } catch (e) {
      _setMessage(error: 'Gagal memperbarui data: $e');
      return false;
    }
  }
}
