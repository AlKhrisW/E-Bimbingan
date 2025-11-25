import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../data/services/user_service.dart';
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