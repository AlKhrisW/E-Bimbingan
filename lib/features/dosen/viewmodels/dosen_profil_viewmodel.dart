import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ebimbingan/features/dosen/viewmodels/ajuan_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dashboard_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_riwayat_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_riwayat_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_mahasiswa_list_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';

import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import '../../auth/views/login_page.dart';

class DosenProfilViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserService _userService = UserService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  DosenProfilViewModel();

  // STATE
  UserModel? _dosenData;
  bool _isLoading = false;

  UserModel? get dosenData => _dosenData;
  bool get isLoading => _isLoading;
  
  String? get currentUserId => AuthUtils().currentUid;

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
    if (!_isDisposed) notifyListeners();
  }

  // =================================================================
  // LOAD DATA
  // =================================================================

  Future<void> loadDosenData() async {
    final uid = AuthUtils().currentUid;
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

  // =================================================================
  // UPDATE PROFILE (Nama & No HP)
  // =================================================================

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    if (_dosenData == null) throw 'Tidak ada data dosen.';
    
    final Map<String, dynamic> payload = {};
    
    // Cek apakah ada perubahan data
    if (name != null && name != _dosenData!.name) {
      payload['name'] = name;
    }
    if (phoneNumber != null && phoneNumber != _dosenData!.phoneNumber) {
      payload['phone_number'] = phoneNumber;
    }

    if (payload.isEmpty) return; // Tidak perlu update jika data sama

    _isLoading = true;
    _safeNotifyListeners();

    try {
      // 1. Update ke Firestore
      await _userService.updateUserMetadataPartial(_dosenData!.uid, payload);
      
      // 2. Update State Lokal (agar UI berubah tanpa reload)
      _dosenData = _dosenData!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      debugPrint('Error updateProfile: $e');
      rethrow; // Lempar error agar ditangkap Widget dan ditampilkan di SnackBar
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
      // Handle error spesifik Firebase
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

  Future<void> handleLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    
    // Clear ViewModel lain sebelum logout
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
    await _authService.signOut();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}