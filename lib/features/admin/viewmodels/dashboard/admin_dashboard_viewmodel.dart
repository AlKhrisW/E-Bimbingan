import 'package:flutter/material.dart';
import '/../data/models/user_model.dart';
import '/../data/services/user_service.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _totalMahasiswa = 0;
  int _totalDosen = 0;
  int _totalAdmin = 0;
  int _totalUnassignedMahasiswa = 0;

  List<UserModel> _unassignedMahasiswa = [];

  // Getters
  int get totalMahasiswa => _totalMahasiswa;
  int get totalDosen => _totalDosen;
  int get totalAdmin => _totalAdmin;
  int get totalUnassignedMahasiswa => _totalUnassignedMahasiswa;
  List<UserModel> get unassignedMahasiswa => _unassignedMahasiswa;

  int get totalUsers => _totalMahasiswa + _totalDosen + _totalAdmin;
  double get assignedPercentage =>
      _totalMahasiswa == 0 ? 0 : ((_totalMahasiswa - _totalUnassignedMahasiswa) / _totalMahasiswa * 100);

  Future<void> loadStatistics() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final allUsers = await _userService.fetchAllUsers();

      _totalMahasiswa = allUsers.where((u) => u.role == 'mahasiswa').length;
      _totalDosen = allUsers.where((u) => u.role == 'dosen').length;
      _totalAdmin = allUsers.where((u) => u.role == 'admin').length;

      final unassigned = await _userService.fetchMahasiswaUnassigned();
      _totalUnassignedMahasiswa = unassigned.length;
      _unassignedMahasiswa = unassigned.take(5).toList(); // Preview 5 orang
    } catch (e) {
      _errorMessage = 'Gagal memuat data: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}