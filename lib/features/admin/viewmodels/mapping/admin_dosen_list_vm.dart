import 'package:flutter/material.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../data/services/user_service.dart';

class AdminDosenListViewModel with ChangeNotifier {
  // --- service ---
  final UserService _userService = UserService();

  // --- state ---
  List<UserModel> _dosenList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // --- getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Daftar dosen yang sudah difilter berdasarkan pencarian
  List<UserModel> get filteredDosenList {
    if (_searchQuery.isEmpty) return _dosenList;

    final queryLower = _searchQuery.toLowerCase();
    return _dosenList.where((dosen) {
      final nameLower = (dosen.name).toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();
  }

  // --- actions ---

  /// Memuat semua dosen dari Firestore
  Future<void> loadDosenList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dosenList = await _userService.fetchDosenList();
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar dosen: ${e.toString()}';
      _dosenList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update query pencarian (dipanggil dari SearchBar)
  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  /// Reset pencarian
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}