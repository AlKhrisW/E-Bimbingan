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

  // =================================================================
  // STATE
  // =================================================================

  UserModel? _dosenData;
  bool _isLoading = false;

  UserModel? get dosenData => _dosenData;
  bool get isLoading => _isLoading;
  String? get currentUserId => _authService.getCurrentUser()?.uid;

  // =================================================================
  // LOAD DATA
  // =================================================================

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

  Future<void> refresh() async {
    await loadDosenData();
  }

  // =================================================================
  // UPDATE PROFILE
  // =================================================================

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    if (_dosenData == null) {
      throw 'Tidak ada data dosen untuk diupdate.';
    }
    
    final Map<String, dynamic> payload = {};
    if (name != null) payload['name'] = name;
    if (phoneNumber != null) payload['phone_number'] = phoneNumber;

    if (payload.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUserMetadataPartial(_dosenData!.uid, payload);
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

  Future<void> updateName(String name) => updateProfile(name: name);
  Future<void> updatePhone(String phone) => updateProfile(phoneNumber: phone);

  // =================================================================
  // LOGOUT
  // =================================================================

  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    // 1. Ambil Navigator SEBELUM proses async (saat context masih valid)
    final navigator = Navigator.of(context);

    // 2. Proses logout
    await logout();

    // 3. Gunakan variabel 'navigator' yang sudah disimpan, BUKAN 'context' lagi
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}