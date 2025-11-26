import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';
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

  /// ----------------------------------------
  /// Update profile fields (name, nip, email, phone)
  /// ----------------------------------------
  Future<void> updateProfile({
    String? name,
    String? nip,
    String? email,
    String? phoneNumber,
  }) async {
    if (_mahasiswaData == null) {
      throw 'Tidak ada data mahasiswa untuk diupdate.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      // create updated model using existing values for fields not provided
      final updated = UserModel(
        uid: _mahasiswaData!.uid,
        name: name ?? _mahasiswaData!.name,
        email: email ?? _mahasiswaData!.email,
        role: _mahasiswaData!.role,
        dosenUid: _mahasiswaData!.dosenUid,
        nim: _mahasiswaData!.nim,
        placement: _mahasiswaData!.placement,
        startDate: _mahasiswaData!.startDate,
        nip: nip ?? _mahasiswaData!.nip,
        jabatan: _mahasiswaData!.jabatan,
        programStudi: _mahasiswaData!.programStudi,
        phoneNumber: phoneNumber ?? _mahasiswaData!.phoneNumber,
      );

      await _userService.updateUserMetadata(updated);

      // update local cache and notify
      _mahasiswaData = updated;
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