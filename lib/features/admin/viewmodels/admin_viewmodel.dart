  // lib/features/admin/viewmodels/admin_viewmodel.dart

  import 'package:flutter/material.dart';
  import 'dart:async';

  import '../../../data/models/user_model.dart';
  import '../../../data/services/user_service.dart';
  import '../../../data/services/firebase_auth_service.dart';
  import '../../../data/services/storage_service.dart';
  import '../../auth/views/login_page.dart';

  class AdminViewModel with ChangeNotifier {
    // --- SERVICE LAYER ---
    final UserService _userService = UserService();
    final FirebaseAuthService _authService = FirebaseAuthService();
    final StorageService _storageService = StorageService();

    // --- STATE ---
    bool _isLoading = false;
    String? _errorMessage;
    String? _successMessage;

    // NEW: currentUser disimpan di ViewModel agar UI bisa listen
    UserModel? _currentUser;
    UserModel? get currentUser => _currentUser;

    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;
    String? get successMessage => _successMessage;

    void _setLoading(bool value) {
      _isLoading = value;
      notifyListeners();
    }

    void _setMessage({String? error, String? success}) {
      _errorMessage = error;
      _successMessage = success;
      notifyListeners();
    }

    // Setter untuk currentUser + notify
    void setCurrentUser(UserModel user) {
      _currentUser = user;
      notifyListeners();
    }

    // Fetch user by uid and update currentUser
    Future<UserModel?> fetchUserByUid(String uid) async {
      try {
        final user = await _userService.fetchUserByUid(uid);
        _currentUser = user;
        notifyListeners();
        return user;
      } catch (e) {
        print('❌ [AdminVM] fetchUserByUid error: $e');
        return null;
      }
    }

    // ========================================================================
    // EXISTING METHODS (TIDAK BERUBAH)
    // ========================================================================

    Future<List<UserModel>> fetchAllUsers() async {
      try {
        return _userService.fetchAllUsers();
      } catch (e) {
        throw 'Gagal memuat semua data pengguna: $e';
      }
    }

    Future<List<UserModel>> fetchDosenList() async {
      try {
        return _userService.fetchDosenList();
      } catch (e) {
        throw 'Gagal memuat daftar dosen: $e';
      }
    }

    Future<void> logout() async {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    Future<void> handleLogout(BuildContext context) async {
      await logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }

    Future<bool> registerUserUniversal({
      required String email,
      required String name,
      required String role,
      required String programStudi,
      required String phoneNumber,
      String? nim,
      String? placement,
      DateTime? startDate,
      String? dosenUid,
      String? nip,
      String? jabatan,
    }) async {
      _setLoading(true);
      _setMessage(error: null, success: null);

      try {
        await _authService.registerUser(
          email: email,
          password: "password",
          name: name,
          role: role,
          programStudi: programStudi,
          phoneNumber: phoneNumber,
          nim: nim,
          placement: placement,
          startDate: startDate,
          dosenUid: dosenUid,
          nip: nip,
          jabatan: jabatan,
        );

        _setMessage(
          success: "Akun $name berhasil didaftarkan! Password default: password.",
        );

        _setLoading(false);
        return true;
      } catch (e) {
        _setMessage(error: e.toString());
        _setLoading(false);
        return false;
      }
    }

    Future<bool> updateUserUniversal({
      required String uid,
      required String email,
      required String name,
      required String role,
      required String programStudi,
      required String phoneNumber,
      String? nim,
      String? placement,
      DateTime? startDate,
      String? dosenUid,
      String? nip,
      String? jabatan,
    }) async {
      _setLoading(true);
      _setMessage(error: null, success: null);

      try {
        final updatedUser = UserModel(
          uid: uid,
          email: email,
          name: name,
          role: role,
          programStudi: programStudi,
          phoneNumber: phoneNumber,
          nim: nim,
          placement: placement,
          startDate: startDate,
          dosenUid: dosenUid,
          nip: nip,
          jabatan: jabatan,
        );

        await _userService.updateUserMetadata(updatedUser);

        _setMessage(success: "Data $name berhasil diperbarui!");
        _setLoading(false);
        return true;
      } catch (e) {
        _setMessage(error: "Gagal memperbarui data: $e");
        _setLoading(false);
        return false;
      }
    }

    Future<bool> deleteUser(String uid) async {
      _setMessage(error: null, success: null);

      try {
        await _authService.deleteUser(uid);
        _setMessage(success: "Pengguna berhasil dihapus!");
        return true;
      } catch (e) {
        _setMessage(error: "Gagal menghapus pengguna: $e");
        return false;
      }
    }

    Future<bool> updateUserData(UserModel user) async {
      _setMessage(error: null, success: null);

      try {
        await _userService.updateUserMetadata(user);
        _setMessage(success: "Data pengguna berhasil diperbarui!");
        return true;
      } catch (e) {
        _setMessage(error: "Gagal memperbarui data: $e");
        return false;
      }
    }

    // ========================================================================
    // PHOTO PROFILE METHODS (SIMPLE - TANPA PARAMETER isFromGallery)
    // ========================================================================

    /// Update foto profil (dari galeri saja)
    Future<bool> updateProfilePhoto(BuildContext context, String uid) async {
      try {
        print('📸 [AdminVM] Starting photo update...');
        _setLoading(true);
        _setMessage(error: null, success: null);

        // 1. Pick image dari galeri
        final imageFile = await _storageService.pickImageFromGallery();

        if (imageFile == null) {
          // User cancel
          print('⚠️ [AdminVM] User cancelled');
          _setLoading(false);
          return false;
        }

        print('✅ [AdminVM] Image selected: ${imageFile.path}');

        // 2. Upload via UserService (saves Base64 to Firestore in your setup)
        final uploadSuccess = await _userService.updateProfilePhoto(uid, imageFile);

        if (!uploadSuccess) {
          _setLoading(false);
          _setMessage(error: "Gagal mengupload foto");
          return false;
        }

        print('✅ [AdminVM] Upload success');

        // 3. AMBIL ULANG DATA USER DARI FIRESTORE supaya UI otomatis update
        final updatedUser = await fetchUserByUid(uid);
        if (updatedUser != null) {
          setCurrentUser(updatedUser);
        }

        _setLoading(false);
        _setMessage(success: "Foto berhasil diupload");
        return true;

      } catch (e) {
        print('❌ [AdminVM] Error: $e');
        _setLoading(false);
        _setMessage(error: e.toString());
        return false;
      }
    }

    /// Hapus foto profil
    Future<bool> removeProfilePhoto(BuildContext context, String uid) async {
      try {
        print('🗑️ [AdminVM] Removing photo...');
        _setLoading(true);
        _setMessage(error: null, success: null);

        // Hapus via UserService
        final deleted = await _userService.removeProfilePhoto(uid);

        if (!deleted) {
          _setLoading(false);
          _setMessage(error: "Gagal menghapus foto");
          return false;
        }

        // Ambil ulang user
        final updatedUser = await fetchUserByUid(uid);
        if (updatedUser != null) {
          setCurrentUser(updatedUser);
        }

        print('✅ [AdminVM] Photo removed');

        _setLoading(false);
        _setMessage(success: "Foto berhasil dihapus");
        return true;

      } catch (e) {
        print('❌ [AdminVM] Error: $e');
        _setLoading(false);
        _setMessage(error: e.toString());
        return false;
      }
    }
  }
