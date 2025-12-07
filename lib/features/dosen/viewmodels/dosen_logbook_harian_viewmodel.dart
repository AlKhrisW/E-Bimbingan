import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/logbook_harian_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';

class DosenLogbookHarianViewModel extends ChangeNotifier {
  final LogbookHarianService _logbookHarianService = LogbookHarianService();
  final UserService _userService = UserService();
  
  DosenLogbookHarianViewModel();

  // =================================================================
  // STATE
  // =================================================================

  List<LogbookHarianModel> _logbookListSource = [];

  LogbookStatus? _activeFilter;
  LogbookStatus? get activeFilter => _activeFilter;

  UserModel? _selectedMahasiswa;
  UserModel? get selectedMahasiswa => _selectedMahasiswa;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // =================================================================
  // GETTERS
  // =================================================================

  List<LogbookHarianModel> get logbooks {
    if (_activeFilter == null) {
      return _logbookListSource;
    }
    return _logbookListSource
        .where((element) => element.status == _activeFilter)
        .toList();
  }

  // =================================================================
  // ACTIONS
  // =================================================================

  void setFilter(LogbookStatus? status) {
    _activeFilter = status;
    notifyListeners();
  }

  Future<void> pilihMahasiswa(String mahasiswaUid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final uid = AuthUtils.currentUid;
    if (uid == null) {
      _errorMessage = "Sesi habis, silakan login ulang";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final mahasiswa = await _userService.fetchUserByUid(mahasiswaUid);
      _selectedMahasiswa = mahasiswa;

      final List<LogbookHarianModel> data = await _logbookHarianService.getLogbook(
        mahasiswaUid, 
        uid 
      );

      _logbookListSource = data;
    } catch (e) {
      _errorMessage = "Gagal memuat logbook: $e";
      _logbookListSource = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_selectedMahasiswa != null) {
      await pilihMahasiswa(_selectedMahasiswa!.uid);
    }
  }
}