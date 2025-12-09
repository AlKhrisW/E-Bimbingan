import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart'; // Import AuthUtils
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/user_service.dart';

class DosenMahasiswaListViewModel extends ChangeNotifier {
  // Inisialisasi service secara internal
  final UserService _userService = UserService();

  // =================================================================
  // STATE
  // =================================================================

  List<UserModel> _mahasiswaList = [];
  List<UserModel> get mahasiswaList => _mahasiswaList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearData() {
    _mahasiswaList = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // =================================================================
  // LOAD DATA
  // =================================================================

  Future<void> loadMahasiswaBimbingan() async {
    final uid = AuthUtils.currentUid;
    
    if (uid == null) {
      _errorMessage = "Tidak ada user yang login";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mahasiswaList = await _userService.fetchMahasiswaByDosenUid(uid);
    } catch (e) {
      _errorMessage = "Gagal memuat daftar mahasiswa: $e";
      _mahasiswaList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadMahasiswaBimbingan();
}