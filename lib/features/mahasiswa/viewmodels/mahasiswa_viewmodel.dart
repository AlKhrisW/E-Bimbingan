import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../data/services/user_service.dart';
import '../../auth/views/login_page.dart';

class MahasiswaViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService;
  final UserService _userService;

  MahasiswaViewModel({
    required FirebaseAuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService;

  UserModel? _mahasiswaData;
  bool _isLoading = false;

  UserModel? get mahasiswaData => _mahasiswaData;
  bool get isLoading => _isLoading;

  /// ----------------------------------------
  /// Mengambil UID mahasiswa yang login saat ini
  /// ----------------------------------------
  String? get currentUserId {
    return _authService.getCurrentUser()?.uid;
  }

  /// ----------------------------------------
  /// Memuat data mahasiswa berdasarkan UID
  /// ----------------------------------------
  Future<void> loadmahasiswaData() async {
    final uid = currentUserId;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _userService.fetchUserByUid(uid);
      _mahasiswaData = data;
    } catch (e) {
      debugPrint("Error load mahasiswa data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ----------------------------------------
  /// Refresh data manual
  /// ----------------------------------------
  Future<void> refresh() async {
    await loadmahasiswaData();
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