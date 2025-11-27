import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import '../../auth/views/login_page.dart';

class DosenProfilViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService;
  final UserService _userService;

  DosenProfilViewModel({
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
  /// Update profile fields (name, phone)
  /// ----------------------------------------
  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    if (_dosenData == null) {
      throw 'Tidak ada data dosen untuk diupdate.';
    }
    // Build partial payload only with provided fields
    final Map<String, dynamic> payload = {};
    if (name != null) payload['name'] = name;
    if (phoneNumber != null) payload['phone_number'] = phoneNumber;

    if (payload.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Use partial update to avoid overwriting unrelated fields
      await _userService.updateUserMetadataPartial(_dosenData!.uid, payload);

      // Update local cache using copyWith
      _dosenData = _dosenData!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
      );
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