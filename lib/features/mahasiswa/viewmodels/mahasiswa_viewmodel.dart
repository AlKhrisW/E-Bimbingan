import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // =================================================================
  // STATE
  // =================================================================

  UserModel? _mahasiswaData;
  bool _isLoading = false;

  UserModel? get mahasiswaData => _mahasiswaData;
  bool get isLoading => _isLoading;
  
  // Menggunakan AuthUtils untuk mengambil UID
  String? get currentUserId => AuthUtils().currentUid;

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
    final uid = AuthUtils().currentUid;
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

  // =================================================================
  // GANTI PASSWORD (Dengan Re-Authentication)
  // =================================================================

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw 'Sesi kadaluarsa. Silakan login ulang.';
    }

    _isLoading = true;
    _safeNotifyListeners();

    try {
      // 1. Buat Kredensial dari Password Lama
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      // 2. Re-Authenticate (Wajib dilakukan sebelum ganti password)
      await user.reauthenticateWithCredential(credential);

      // 3. Update Password Baru
      await user.updatePassword(newPassword);

      debugPrint("Password berhasil diubah di Firebase Auth");
    } on FirebaseAuthException catch (e) {
      // Handle error spesifik Firebase agar pesan user-friendly
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw 'Password lama salah.';
      } else if (e.code == 'weak-password') {
        throw 'Password baru terlalu lemah (minimal 6 karakter).';
      } else if (e.code == 'requires-recent-login') {
        throw 'Demi keamanan, silakan logout dan login kembali sebelum mengganti password.';
      } else {
        throw 'Gagal mengganti password: ${e.message}';
      }
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

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