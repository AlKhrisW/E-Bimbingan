// lib/features/admin/viewmodels/admin_user_management_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/firebase_auth_service.dart';

class AdminUserManagementViewModel with ChangeNotifier {
  // --- SERVICE LAYER (injectable) ---
  final UserService _userService;
  final FirebaseAuthService _authService;

  AdminUserManagementViewModel({
    UserService? userService,
    FirebaseAuthService? authService,
  })  : _userService = userService ?? UserService(),
        _authService = authService ?? FirebaseAuthService();

  // --- STATE ---
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<UserModel> _users = [];

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<UserModel> get users => _users;

  // --- PRIVATE HELPERS ---
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

  // --- TESTING HELPER ---
  @visibleForTesting
  set users(List<UserModel> value) {
    _users = value;
    notifyListeners();
  }

  // ========================================================================
  // READ METHODS
  // ========================================================================

  Future<void> loadAllUsers() async {
    _setLoading(true);
    resetMessages();
    try {
      _users = await _userService.fetchAllUsers();
    } catch (e) {
      _setMessage(error: 'Gagal memuat daftar pengguna: ${e.toString()}');
      _users = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDosenList() async {
    _setLoading(true);
    resetMessages();
    try {
      _users = await _userService.fetchDosenList();
    } catch (e) {
      _setMessage(error: 'Gagal memuat daftar dosen: ${e.toString()}');
      _users = [];
    } finally {
      _setLoading(false);
    }
  }

  // ========================================================================
  // CREATE - REGISTER USER
  // ========================================================================

  Future<bool> registerUserUniversal({
    required String email,
    required String name,
    required String role,
    String? programStudi,
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

  // ========================================================================
  // UPDATE USER
  // ========================================================================

  Future<bool> updateUserUniversal({
    required String uid,
    required String email,
    required String name,
    required String role,
    String? programStudi,
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

      int index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      } else {
        await loadAllUsers();
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

  // ========================================================================
  // DELETE USER
  // ========================================================================

  Future<bool> deleteUser(String uid) async {
    _setLoading(true);
    resetMessages();

    try {
      await _authService.deleteUser(uid);

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
