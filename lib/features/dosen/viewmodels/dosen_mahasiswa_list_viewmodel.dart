import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';

class DosenMahasiswaViewModel extends ChangeNotifier {
  final UserService _userService;
  final FirebaseAuthService _authService;

  DosenMahasiswaViewModel({
    required UserService userService,
    required FirebaseAuthService authService,
  })  : _userService = userService,
        _authService = authService;

  List<UserModel> _mahasiswaList = [];
  List<UserModel> get mahasiswaList => _mahasiswaList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Load mahasiswa by explicit dosen UID
  Future<void> loadByDosenUid(String dosenUid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _userService.fetchMahasiswaByDosenUid(dosenUid);
      _mahasiswaList = list;
    } on Exception catch (e) {
      // Handle Firestore / network errors gracefully.
      debugPrint('Error loadByDosenUid: $e');
      // Do not rethrow to avoid crashing the UI; keep the list empty.
      _mahasiswaList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Convenience: load mahasiswa for currently logged in dosen
  Future<void> loadForCurrentDosen() async {
    final uid = _authService.getCurrentUser()?.uid;
    if (uid == null) return;
    await loadByDosenUid(uid);
  }

  /// Refresh (re-run last load). If current user available, load for current dosen.
  Future<void> refresh() async {
    await loadForCurrentDosen();
  }
}
