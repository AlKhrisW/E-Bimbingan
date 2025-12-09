import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/helper_ajuan_bimbingan.dart'; 
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

class DosenRiwayatAjuanViewModel extends ChangeNotifier {
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final UserService _userService = UserService();
  
  DosenRiwayatAjuanViewModel();

  // =================================================================
  // STATE
  // =================================================================

  List<AjuanWithMahasiswa> _riwayatListSource = [];

  AjuanStatus? _activeFilter;
  AjuanStatus? get activeFilter => _activeFilter;

  UserModel? _selectedMahasiswa;
  UserModel? get selectedMahasiswa => _selectedMahasiswa;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearData() {
    _riwayatListSource = [];
    _activeFilter = null;
    _selectedMahasiswa = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // =================================================================
  // GETTERS
  // =================================================================

  List<AjuanWithMahasiswa> get riwayatList {
    if (_activeFilter == null) {
      return _riwayatListSource;
    }
    return _riwayatListSource
        .where((element) => element.ajuan.status == _activeFilter)
        .toList();
  }

  // =================================================================
  // ACTIONS
  // =================================================================

  void setFilter(AjuanStatus? status) {
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

      final List<AjuanBimbinganModel> data = await _ajuanService.getRiwayatSpesifik(
        uid, 
        mahasiswaUid,
      );

      final filteredData = data.where((ajuan) => 
          ajuan.status == AjuanStatus.disetujui || 
          ajuan.status == AjuanStatus.ditolak
      ).toList();

      List<AjuanWithMahasiswa> tempList = filteredData.map((ajuan) {
        return AjuanWithMahasiswa(
          ajuan: ajuan,
          mahasiswa: mahasiswa,
        );
      }).toList();

      tempList.sort((a, b) => b.ajuan.waktuDiajukan.compareTo(a.ajuan.waktuDiajukan));
      _riwayatListSource = tempList;

    } catch (e) {
      _errorMessage = "Gagal memuat riwayat: $e";
      _riwayatListSource = [];
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

  // =================================================================
  // NEW: FETCH SINGLE DETAIL (Untuk Notifikasi)
  // =================================================================
  
  /// Mengambil data lengkap (Ajuan + Mahasiswa) berdasarkan ID.
  Future<AjuanWithMahasiswa?> getAjuanDetail(String ajuanUid) async {
    try {
      // 1. Ambil data Ajuan by ID
      final AjuanBimbinganModel? ajuan = await _ajuanService.getAjuanByUid(ajuanUid);
      
      if (ajuan == null) return null;

      // 2. Ambil data Mahasiswa
      final mahasiswa = await _userService.fetchUserByUid(ajuan.mahasiswaUid);

      // 3. Return wrapper
      return AjuanWithMahasiswa(
        ajuan: ajuan,
        mahasiswa: mahasiswa,
      );
    } catch (e) {
      debugPrint("Error fetching detail for notification: $e");
      return null;
    }
  }
}