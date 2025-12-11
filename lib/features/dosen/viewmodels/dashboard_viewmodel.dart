import 'dart:async';
import 'package:flutter/material.dart';

// Utils & Models
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/dosen_helper_dashboard.dart';

// Services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

class DosenDashboardViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();

  // ================================================================
  // STATE
  // ================================================================
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  List<DosenDashboardHelper> _jadwalList = [];
  List<DosenDashboardHelper> get jadwalTampil => _jadwalList;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _timer;
  final int _defaultDurationMinutes = 60;

  void clearData() {
    _jadwalList = [];
    _timer?.cancel();
    _timer = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // =================================================================
  // INIT
  // =================================================================

  void init() {
    loadDashboardData();
    // Timer untuk cek waktu setiap menit (agar card hilang otomatis)
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _filterJadwalTime(); 
    });
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // =================================================================
  // CORE LOGIC
  // =================================================================

  Future<void> loadDashboardData() async {
    // 1. Cek UID di awal
    final uid = AuthUtils().currentUid;
    if (uid == null) {
      _errorMessage = "Sesi berakhir.";
      _isLoading = false;
      _safeNotifyListeners(); 
      return;
    }

    _isLoading = true;
    _safeNotifyListeners();

    try {
      // 2. Fetch User Profile
      if (_isDisposed) return;
      _currentUser = await _userService.fetchUserByUid(uid);

      // 3. Fetch Jadwal
      if (_isDisposed) return;
      final List<AjuanBimbinganModel> rawJadwal = await _ajuanService.getJadwalDosen(uid);
      
      // 4. Wrapping Process
      if (_isDisposed) return;
      await _processWrapping(rawJadwal);

    } catch (e) {
      _errorMessage = "Gagal memuat dashboard: $e";
      _jadwalList = [];
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _processWrapping(List<AjuanBimbinganModel> rawList) async {
    if (rawList.isEmpty) {
      _jadwalList = [];
      return;
    }

    try {
      // A. Kumpulkan UID Mahasiswa Unik
      final Set<String> mhsUids = rawList.map((e) => e.mahasiswaUid).toSet();

      // B. Fetch Data Mahasiswa (Batch/Loop)
      final List<UserModel> fetchedMhs = [];
      for (var uid in mhsUids) {
        try {
          final m = await _userService.fetchUserByUid(uid);
          fetchedMhs.add(m);
        } catch (e) {
          debugPrint("Gagal fetch mahasiswa $uid: $e");
        }
      }

      // C. Buat Map UID -> UserModel
      final Map<String, UserModel> mhsMap = { 
        for (var m in fetchedMhs) m.uid: m 
      };

      // D. Gabungkan menjadi Helper
      List<DosenDashboardHelper> tempList = [];
      for (var ajuan in rawList) {
        final mahasiswa = mhsMap[ajuan.mahasiswaUid];
        
        if (mahasiswa != null) {
          tempList.add(DosenDashboardHelper(
            ajuan: ajuan,
            mahasiswa: mahasiswa,
          ));
        }
      }

      // E. Filter Waktu & Sort
      _jadwalList = _applyFilterAndSort(tempList);

    } catch (e) {
      debugPrint("Error processing wrapper: $e");
      _jadwalList = [];
    }
  }

  void _filterJadwalTime() {
    if (_currentUser != null && AuthUtils().currentUid != null) {
       loadDashboardData(); 
    } else {
      // Jika user null, matikan timer untuk keamanan
      _timer?.cancel();
      _timer = null;
    }
  }

  List<DosenDashboardHelper> _applyFilterAndSort(List<DosenDashboardHelper> list) {
    final now = DateTime.now();

    // 1. Filter: Hanya tampilkan jika waktu belum lewat (Start + Durasi > Sekarang)
    var filtered = list.where((helper) {
      DateTime? waktuSelesai = _hitungEstimasiSelesai(
        helper.ajuan.tanggalBimbingan, 
        helper.ajuan.waktuBimbingan
      );

      // Jika parsing gagal, anggap valid (tampilkan saja)
      if (waktuSelesai == null) return true; 
      
      return now.isBefore(waktuSelesai);
    }).toList();

    // 2. Sorting: Tanggal terdekat -> Jam terdekat
    filtered.sort((a, b) {
      int compareDate = a.ajuan.tanggalBimbingan.compareTo(b.ajuan.tanggalBimbingan);
      if (compareDate == 0) {
        return a.ajuan.waktuBimbingan.compareTo(b.ajuan.waktuBimbingan);
      }
      return compareDate;
    });

    return filtered;
  }

  DateTime? _hitungEstimasiSelesai(DateTime tanggal, String jamMulaiString) {
    try {
      final cleanTime = jamMulaiString.replaceAll('.', ':').trim(); 
      final parts = cleanTime.split(':');
      if (parts.length < 2) return null;
      
      final jam = int.parse(parts[0]);
      final menit = int.parse(parts[1]);

      final waktuMulai = DateTime(tanggal.year, tanggal.month, tanggal.day, jam, menit);
      // Tambah durasi default
      return waktuMulai.add(Duration(minutes: _defaultDurationMinutes));
    } catch (e) {
      return null;
    }
  }
}