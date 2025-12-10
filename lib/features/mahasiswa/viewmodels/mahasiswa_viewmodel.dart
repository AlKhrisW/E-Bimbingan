import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import ViewModel Fitur Mahasiswa
import 'ajuan_bimbingan_viewmodel.dart';
import 'log_mingguan_viewmodel.dart';
import 'log_harian_viewmodel.dart';
import 'mahasiswa_dashboard_viewmodel.dart';

// Import lainnya
import 'package:ebimbingan/data/services/firebase_auth_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';
import '../../auth/views/login_page.dart';

class MahasiswaViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserService _userService = UserService();

  // =================================================================
  // STATE
  // =================================================================

  UserModel? _mahasiswaData;
  bool _isLoading = false;

  UserModel? get mahasiswaData => _mahasiswaData;
  bool get isLoading => _isLoading;
  
  // Menggunakan AuthUtils untuk mengambil UID
  String? get currentUserId => AuthUtils.currentUid;

  void clearData() {
    _mahasiswaData = null;
    _isLoading = false;
    notifyListeners();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // =================================================================
  // LOAD DATA
  // =================================================================

  Future<void> loadmahasiswaData() async {
    // Menggunakan AuthUtils
    final uid = AuthUtils.currentUid;
    if (uid == null) return;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      final data = await _userService.fetchUserByUid(uid);
      _mahasiswaData = data;
    } catch (e) {
      debugPrint("Error load mahasiswa data: $e");
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refresh() async {
    await loadmahasiswaData();
  }

  // =================================================================
  // UPDATE PROFILE
  // =================================================================

  /// Update hanya Nama dan No HP (NIM dan Email dihapus sesuai permintaan)
  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    if (_mahasiswaData == null) {
      throw 'Tidak ada data mahasiswa untuk diupdate.';
    }

    // 1. Siapkan payload partial
    final Map<String, dynamic> payload = {};
    if (name != null) payload['name'] = name;
    if (phoneNumber != null) payload['phone_number'] = phoneNumber;

    if (payload.isEmpty) return;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      // 2. Kirim ke Firestore (hanya field yang berubah)
      await _userService.updateUserMetadataPartial(_mahasiswaData!.uid, payload);

      // 3. Update local state
      _mahasiswaData = _mahasiswaData!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      debugPrint('Error updateProfile: $e');
      rethrow;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Helper functions (NIM dan Email dihapus)
  Future<void> updateName(String name) => updateProfile(name: name);
  Future<void> updatePhone(String phone) => updateProfile(phoneNumber: phone);

  // =================================================================
  // LOGOUT
  // =================================================================

  Future<void> logout() async {
    clearData();
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    final navigator = Navigator.of(context);

    if (context.mounted) {
        context.read<MahasiswaDashboardViewModel>().clearData();
        context.read<MahasiswaAjuanBimbinganViewModel>().clearData();
        context.read<MahasiswaLogMingguanViewModel>().clearData();
        context.read<MahasiswaLogHarianViewModel>().clearData();
    }

    await Future.delayed(const Duration(milliseconds: 250));

    await logout();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}