import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // [Wajib Import Provider]

// Import ViewModel Fitur Dosen
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dashboard_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_riwayat_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_riwayat_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_mahasiswa_list_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';

// Import standar lainnya
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

  void clearData() {
    _dosenData = null;
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

  Future<void> loadDosenData() async {
    // Menggunakan AuthUtils
    final uid = AuthUtils.currentUid;
    if (uid == null) return;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      final data = await _userService.fetchUserByUid(uid);
      _dosenData = data;
    } catch (e) {
      debugPrint("Error load dosen data: $e");
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
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
    _safeNotifyListeners();

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
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

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
    // 1. Tangkap Navigator & Provider selagi context masih mounted
    final navigator = Navigator.of(context);
    
    // 2. Bersihkan ViewModel lain SEBELUM logout auth
    if (context.mounted) {
        context.read<DosenDashboardViewModel>().clearData();
        context.read<DosenAjuanViewModel>().clearData();
        context.read<DosenBimbinganViewModel>().clearData();
        context.read<DosenLogbookHarianViewModel>().clearData();
        context.read<DosenRiwayatAjuanViewModel>().clearData();
        context.read<DosenRiwayatBimbinganViewModel>().clearData();
        context.read<DosenMahasiswaListViewModel>().clearData();
    }

    await Future.delayed(const Duration(milliseconds: 250));

    // 3. Lakukan Logout Auth
    await logout();

    // 4. Navigasi ke Login Page
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}