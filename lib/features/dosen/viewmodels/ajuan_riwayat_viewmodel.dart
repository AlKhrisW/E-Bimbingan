import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';

// models
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/helper_ajuan_bimbingan.dart'; 

// services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

class DosenRiwayatAjuanViewModel extends ChangeNotifier {
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final UserService _userService = UserService();
  
  late final String currentDosenUid;

  DosenRiwayatAjuanViewModel() {
    currentDosenUid = AuthUtils.currentUid ?? '';
  }

  // =================================================================
  // STATE
  // =================================================================

  // List utama dari database, sekarang menggunakan wrapper Helper/Wrapper
  List<AjuanWithMahasiswa> _riwayatListSource = [];

  // Filter aktif (null = Semua, Disetujui, Ditolak)
  AjuanStatus? _activeFilter;
  AjuanStatus? get activeFilter => _activeFilter;

  // Data detail mahasiswa yang sedang dilihat
  UserModel? _selectedMahasiswa;
  UserModel? get selectedMahasiswa => _selectedMahasiswa;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // =================================================================
  // GETTERS (UI LOGIC)
  // =================================================================

  /// Mengambil list yang sudah difilter sesuai bubble pilihan user
  List<AjuanWithMahasiswa> get riwayatList {
    if (_activeFilter == null) {
      return _riwayatListSource;
    }
    return _riwayatListSource
        .where((element) => element.ajuan.status == _activeFilter)
        .toList();
  }

  // =================================================================
  // ACTIONS & METHODS
  // =================================================================

  void setFilter(AjuanStatus? status) {
    _activeFilter = status;
    notifyListeners();
  }

  /// Memuat data mahasiswa dan riwayat bimbingannya
  Future<void> pilihMahasiswa(String mahasiswaUid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil detail mahasiswa untuk Header UI dan Wrapper
      final mahasiswa = await _userService.fetchUserByUid(mahasiswaUid);
      _selectedMahasiswa = mahasiswa;

      // 2. Ambil Riwayat Spesifik (Future)
      final List<AjuanBimbinganModel> data = await _ajuanService.getRiwayatSpesifik(
        currentDosenUid, 
        mahasiswaUid,
      );

      // 3. Filter: Hanya ambil yang statusnya Disetujui atau Ditolak
      final filteredData = data.where((ajuan) => 
          ajuan.status == AjuanStatus.disetujui || 
          ajuan.status == AjuanStatus.ditolak
      ).toList();

      // 4. Mapping ke Helper (AjuanWithMahasiswa)
      List<AjuanWithMahasiswa> tempList = filteredData.map((ajuan) {
        return AjuanWithMahasiswa(
          ajuan: ajuan,
          mahasiswa: mahasiswa, // Menggunakan mahasiswa yang sudah difetch di step 1
        );
      }).toList();

      // 5. Sorting: Waktu terbaru di atas
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

  // =================================================================
  // UTILS
  // =================================================================

  Future<void> refresh() async {
    if (_selectedMahasiswa != null) {
      await pilihMahasiswa(_selectedMahasiswa!.uid);
    }
  }
}