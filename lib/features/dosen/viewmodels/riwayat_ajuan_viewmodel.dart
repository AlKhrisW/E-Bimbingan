import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';

// models
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';

// services
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';

class DosenRiwayatAjuanViewModel extends ChangeNotifier {
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final UserService _userService = UserService();
  
  late final String currentDosenUid;

  DosenRiwayatAjuanViewModel() {
    currentDosenUid = AuthUtils.currentUid ?? '';
  }

  // --- Data & State ---

  // List utama dari database (Disetujui & Ditolak)
  List<AjuanBimbinganModel> _riwayatListSource = [];

  // Filter aktif untuk bubble (null = Tampilkan Semua)
  AjuanStatus? _activeFilter;
  AjuanStatus? get activeFilter => _activeFilter;

  // Data detail mahasiswa yang sedang dilihat
  UserModel? _selectedMahasiswa;
  UserModel? get selectedMahasiswa => _selectedMahasiswa;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _subscription;

  // --- Getters ---

  // Mengambil list yang sudah difilter sesuai bubble yang dipilih user
  List<AjuanBimbinganModel> get riwayatList {
    if (_activeFilter == null) {
      return _riwayatListSource;
    }
    return _riwayatListSource
        .where((element) => element.status == _activeFilter)
        .toList();
  }

  // --- Methods ---

  /// Mengubah status filter saat bubble ditekan
  void setFilter(AjuanStatus? status) {
    _activeFilter = status;
    notifyListeners();
  }

  /// Memuat data mahasiswa dan riwayat bimbingannya
  Future<void> pilihMahasiswa(String mahasiswaUid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _subscription?.cancel();

    try {
      // 1. Ambil detail mahasiswa untuk Header UI
      final mahasiswa = await _userService.fetchUserByUid(mahasiswaUid);
      _selectedMahasiswa = mahasiswa;

      // 2. Subscribe ke stream riwayat spesifik
      _subscription = _ajuanService
          .getRiwayatSpesifik(currentDosenUid, mahasiswaUid)
          .listen((data) {
            
        // 3. Filter data dari database: Hanya ambil Disetujui atau Ditolak
        // Status 'Proses' tidak ditampilkan di halaman riwayat
        final filteredData = data.where((ajuan) => 
            ajuan.status == AjuanStatus.disetujui || 
            ajuan.status == AjuanStatus.ditolak
        ).toList();

        // 4. Sorting: Waktu terbaru di atas
        filteredData.sort((a, b) => b.waktuDiajukan.compareTo(a.waktuDiajukan));

        _riwayatListSource = filteredData;
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _errorMessage = "Gagal memuat riwayat: $e";
        _riwayatListSource = [];
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = "Gagal memuat data mahasiswa: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload data manual
  void refresh() {
    if (_selectedMahasiswa != null) {
      pilihMahasiswa(_selectedMahasiswa!.uid);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}