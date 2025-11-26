import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import '../../auth/views/login_page.dart';

class DosenViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService;
  final UserService _userService;

  DosenViewModel({
    required FirebaseAuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService;

  UserModel? _dosenData;
  bool _isLoading = false;

  UserModel? get dosenData => _dosenData;
  bool get isLoading => _isLoading;

  /// ----------------------------------------
  /// Mengambil UID dosen yang login saat ini
  /// ----------------------------------------
  String? get currentUserId {
    return _authService.getCurrentUser()?.uid;
  }

  /// ----------------------------------------
  /// Memuat data dosen berdasarkan UID
  /// ----------------------------------------
  Future<void> loadDosenData() async {
    final uid = currentUserId;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _userService.fetchUserByUid(uid);
      _dosenData = data;
    } catch (e) {
      debugPrint("Error load dosen data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ----------------------------------------
  /// Refresh data manual
  /// ----------------------------------------
  Future<void> refresh() async {
    await loadDosenData();
  }

  /// ----------------------------------------
  /// Update profile fields (name, nip, email, phone)
  /// ----------------------------------------
  Future<void> updateProfile({
    String? name,
    String? nip,
    String? email,
    String? phoneNumber,
  }) async {
    if (_dosenData == null) {
      throw 'Tidak ada data dosen untuk diupdate.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      // create updated model using existing values for fields not provided
      final updated = UserModel(
        uid: _dosenData!.uid,
        name: name ?? _dosenData!.name,
        email: email ?? _dosenData!.email,
        role: _dosenData!.role,
        dosenUid: _dosenData!.dosenUid,
        nim: _dosenData!.nim,
        placement: _dosenData!.placement,
        startDate: _dosenData!.startDate,
        nip: nip ?? _dosenData!.nip,
        jabatan: _dosenData!.jabatan,
        programStudi: _dosenData!.programStudi,
        phoneNumber: phoneNumber ?? _dosenData!.phoneNumber,
      );

      await _userService.updateUserMetadata(updated);

      // update local cache and notify
      _dosenData = updated;
    } catch (e) {
      debugPrint('Error updateProfile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Convenience helpers
  Future<void> updateName(String name) => updateProfile(name: name);
  Future<void> updateNip(String? nip) => updateProfile(nip: nip);
  Future<void> updateEmail(String email) => updateProfile(email: email);
  Future<void> updatePhone(String phone) => updateProfile(phoneNumber: phone);

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------
  // Logic logout (hapus token dll)
  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Handle logout + navigate ke login
  Future<void> handleLogout(BuildContext context) async {
    await logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}