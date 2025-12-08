import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import '../../auth/views/login_page.dart';

class DosenProfilViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserService _userService = UserService();

  DosenProfilViewModel();

  // =================================================================
  // STATE
  // =================================================================

  UserModel? _dosenData;
  bool _isLoading = false;

  UserModel? get dosenData => _dosenData;
  bool get isLoading => _isLoading;
  
  String? get currentUserId => AuthUtils.currentUid;

  // =================================================================
  // LOAD DATA
  // =================================================================

  Future<void> loadDosenData() async {
    // Menggunakan AuthUtils
    final uid = AuthUtils.currentUid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _userService.fetchUserByUid(uid);
      _dosenData = data;
    } catch (e) {
      debugPrint("Error load dosen data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    final navigator = Navigator.of(context);

    await logout();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}