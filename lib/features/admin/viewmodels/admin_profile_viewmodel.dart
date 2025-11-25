// lib/features/admin/viewmodels/admin_profile_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/storage_service.dart';

class AdminProfileViewModel with ChangeNotifier {
  // --- SERVICE LAYER ---
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  // --- STATE ---
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserModel? _currentUser; // Data profil yang sedang ditampilkan

  // --- GETTERS ---
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // --- PRIVATE HELPERS ---
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setMessage({String? error, String? success}) {
    _errorMessage = error;
    _successMessage = success;
    notifyListeners();
  }
  
  /// Setter untuk _currentUser (digunakan di View initState untuk inisialisasi)
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void resetMessages() {
    _setMessage(error: null, success: null);
  }

  // ========================================================================
  // CORE PROFILE METHODS
  // ========================================================================
  
  /// Mengambil data user berdasarkan UID dan menyimpannya di _currentUser
  Future<void> fetchUser(String uid) async {
    _setLoading(true);
    resetMessages();
    try {
      _currentUser = await _userService.fetchUserByUid(uid);
    } catch (e) {
      print('❌ [ProfileVM] fetchUser error: $e');
      _setMessage(error: 'Gagal memuat data pengguna: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Mengupdate data pengguna (selain foto)
  Future<bool> updateUserData(UserModel user) async {
    _setLoading(true);
    resetMessages();
    try {
      await _userService.updateUserMetadata(user);
      _currentUser = user; // Update state lokal
      _setMessage(success: "Data pengguna berhasil diperbarui!");
      return true;
    } catch (e) {
      _setMessage(error: "Gagal memperbarui data: ${e.toString()}");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========================================================================
  // PHOTO PROFILE METHODS
  // ========================================================================

  /// Mengupdate foto profil dari galeri
  Future<bool> updateProfilePhoto(BuildContext context, String uid) async {
    _setLoading(true);
    resetMessages();
    try {
      final imageFile = await _storageService.pickImageFromGallery();
      if (imageFile == null) {
        _setLoading(false);
        return false; 
      }

      final success = await _userService.updateProfilePhoto(uid, imageFile);
      
      if (!success) {
        _setMessage(error: "Gagal mengupload foto");
        return false;
      }

      // Refresh data user agar UI otomatis menampilkan foto baru
      await fetchUser(uid); 
      _setMessage(success: "Foto profil berhasil diupdate");
      return true;
    } catch (e) {
      _setMessage(error: 'Gagal mengupload: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Menghapus foto profil
  Future<bool> removeProfilePhoto(String uid) async {
    _setLoading(true);
    resetMessages();
    try {
      final success = await _userService.removeProfilePhoto(uid);
      
      if (success) {
        // Refresh data user agar currentUser di-update dengan photoUrl = null
        await fetchUser(uid); 
        _setMessage(success: "Foto profil berhasil dihapus");
        return true;
      }
      
      _setMessage(error: "Gagal menghapus foto");
      return false;
    } catch (e) {
      _setMessage(error: 'Gagal menghapus: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}