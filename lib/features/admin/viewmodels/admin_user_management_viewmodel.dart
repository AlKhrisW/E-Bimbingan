// lib/features/admin/viewmodels/admin_user_management_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/firebase_auth_service.dart';

class AdminUserManagementViewModel with ChangeNotifier {
  // --- SERVICE LAYER ---
  final UserService _userService = UserService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  // --- STATE ---
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<UserModel> _users = []; // List untuk AdminUsersScreen

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<UserModel> get users => _users;

  // --- PRIVATE HELPERS ---
  // ⭐ TIDAK ADA PERUBAHAN. notifyListeners() dipanggil di sini.
  void _setLoading(bool v) { 
    _isLoading = v;
    notifyListeners();
  }

  void _setMessage({String? error, String? success}) {
    _errorMessage = error;
    _successMessage = success;
    notifyListeners();
  }

  void resetMessages() {
    _setMessage(error: null, success: null);
  }

  // ========================================================================
  // READ METHODS
  // ========================================================================
  
  /// Memuat semua pengguna (untuk AdminUsersScreen)
  Future<void> loadAllUsers() async {
    _setLoading(true); // Memanggil notifyListeners()
    resetMessages();
    try {
      _users = await _userService.fetchAllUsers();
    } catch (e) {
      _setMessage(error: 'Gagal memuat daftar pengguna: ${e.toString()}');
      _users = [];
    } finally {
      _setLoading(false); // Memanggil notifyListeners()
    }
  }

  /// Memuat daftar Dosen saja
  Future<void> loadDosenList() async {
    _setLoading(true); // Memanggil notifyListeners()
    resetMessages();
    try {
      // NOTE: Saya asumsikan fetchDosenList hanya mengambil dosen.
      _users = await _userService.fetchDosenList();
    } catch (e) {
      _setMessage(error: 'Gagal memuat daftar dosen: ${e.toString()}');
      _users = [];
    } finally {
      _setLoading(false); // Memanggil notifyListeners()
    }
  }

  // ... (CRUD methods lainnya tidak berubah)
  
  /// Mendaftarkan pengguna baru (CREATE)
  Future<bool> registerUserUniversal({
    required String email,
    required String name,
    required String role,
    required String programStudi,
    required String phoneNumber,
    String? nim,
    String? placement,
    DateTime? startDate,
    String? dosenUid,
    String? nip,
    String? jabatan,
  }) async {
    _setLoading(true);
    resetMessages();

    try {
      await _authService.registerUser(
        email: email,
        password: "password",
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

      // Refresh list pengguna (Penting)
      await loadAllUsers();

      _setMessage(
        success: "Akun $name berhasil didaftarkan! Password default: password.",
      );
      return true;
    } catch (e) {
      _setMessage(error: e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Memperbarui data pengguna (UPDATE)
  Future<bool> updateUserUniversal({
    required String uid,
    required String email,
    required String name,
    required String role,
    required String programStudi,
    required String phoneNumber,
    String? nim,
    String? placement,
    DateTime? startDate,
    String? dosenUid,
    String? nip,
    String? jabatan,
  }) async {
    _setLoading(true);
    resetMessages();

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

      // Update list pengguna secara lokal (lebih efisien)
      int index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners(); 
      } else {
        await loadAllUsers(); // Jika tidak ditemukan, load ulang
      }

      _setMessage(success: "Data $name berhasil diperbarui!");
      return true;
    } catch (e) {
      _setMessage(error: "Gagal memperbarui data: ${e.toString()}");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Menghapus pengguna (DELETE)
  Future<bool> deleteUser(String uid) async {
    _setLoading(true);
    resetMessages();
    
    try {
      await _authService.deleteUser(uid);
      
      // Hapus dari list lokal dan panggil notifyListeners
      _users.removeWhere((u) => u.uid == uid);
      notifyListeners();
      
      _setMessage(success: "Pengguna berhasil dihapus!");
      return true;
    } catch (e) {
      _setMessage(error: "Gagal menghapus pengguna: ${e.toString()}");
      return false;
    } finally {
      _setLoading(false);
    }
  }
}