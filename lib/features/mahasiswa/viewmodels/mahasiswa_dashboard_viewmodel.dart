import 'dart:async';
import 'package:flutter/material.dart';

// Utils
import 'package:ebimbingan/core/utils/auth_utils.dart';

// Models & Helper
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_dashboard.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';

// Services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/data/services/logbook_harian_service.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';

class MahasiswaDashboardViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final LogbookHarianService _logbookService = LogbookHarianService();
  final LogBimbinganService _logBimbinganService = LogBimbinganService();
  
  // =================================================================
  // STATE
  // =================================================================
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  List<DashboardScheduleHelper> _jadwalList = [];
  List<DashboardScheduleHelper> get jadwalTampil => _jadwalList;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _timer;
  final int _defaultDurationMinutes = 60;

  // --- STATE PROGRESS ---
  int _totalDaysInternship = 0;
  int _totalWeeksInternship = 0;
  int _logbookFilledCount = 0;
  int _bimbinganFilledCount = 0;

  int get totalDays => _totalDaysInternship;
  int get totalWeeks => _totalWeeksInternship;
  int get logbookFilled => _logbookFilledCount;
  int get bimbinganFilled => _bimbinganFilledCount;

  double get logbookProgress {
    if (_totalDaysInternship == 0) return 0.0;
    double progress = _logbookFilledCount / _totalDaysInternship;
    return progress > 1.0 ? 1.0 : progress; 
  }

  double get bimbinganProgress {
    if (_totalWeeksInternship == 0) return 0.0;
    double progress = _bimbinganFilledCount / _totalWeeksInternship;
    return progress > 1.0 ? 1.0 : progress;
  }

   void clearData() {
      _jadwalList = [];
      _logbookFilledCount = 0;
      _bimbinganFilledCount = 0;
      _timer?.cancel();
      _timer = null;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }

  // =================================================================
  // INIT & DISPOSE
  // =================================================================

  void init() {
    loadDashboardData();
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
      if (_isDisposed) return;
      _currentUser = await _userService.fetchUserByUid(uid);

      // --- LOGIC PROGRESS ---
      _calculateInternshipTargets();
      await _fetchProgressCounts(uid);

      // --- LOGIC JADWAL ---
      if (_currentUser?.dosenUid == null || _currentUser!.dosenUid!.isEmpty) {
        _jadwalList = [];
      } else {
        if (_isDisposed) return;
        final List<AjuanBimbinganModel> rawJadwal = await _ajuanService.getJadwalMahasiswa(
          uid, 
          _currentUser!.dosenUid!
        );
        
        if (_isDisposed) return;
        await _processWrapping(rawJadwal);
      }

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

  // 1. Hitung Target Hari & Minggu dari UserModel
  void _calculateInternshipTargets() {
    if (_currentUser?.startDate == null || _currentUser?.endDate == null) {
      _totalDaysInternship = 0;
      _totalWeeksInternship = 0;
      return;
    }

    final start = _currentUser!.startDate!;
    final end = _currentUser!.endDate!;
    
    // Selisih hari (+1 agar inklusif)
    final diffDays = end.difference(start).inDays + 1;
    
    _totalDaysInternship = diffDays > 0 ? diffDays : 0;
    _totalWeeksInternship = (_totalDaysInternship / 7).truncate();
  }

  // 2. Ambil Jumlah Data Real (HANYA YANG APPROVED/VERIFIED)
  Future<void> _fetchProgressCounts(String uid) async {
    try {
      // Ambil semua data mentah
      final List<LogbookHarianModel> allLogbooks = 
          await _logbookService.getLogbookByMahasiswaUid(uid);
      
      final List<LogBimbinganModel> allBimbingans = 
          await _logBimbinganService.getLogBimbinganByMahasiswaUid(uid);
      
      // Logbook Harian -> Harus 'verified'
      _logbookFilledCount = allLogbooks
          .where((log) => log.status == LogbookStatus.verified)
          .length;

      // Log Bimbingan -> Harus 'approved'
      _bimbinganFilledCount = allBimbingans
          .where((log) => log.status == LogBimbinganStatus.approved)
          .length;

    } catch (e) {
      debugPrint("Gagal hitung progress: $e");
      // Tidak throw error agar dashboard tetap jalan
    }
  }

  Future<void> _processWrapping(List<AjuanBimbinganModel> rawList) async {
    if (rawList.isEmpty) {
      _jadwalList = [];
      return;
    }

    try {
      final Set<String> dosenUids = rawList.map((e) => e.dosenUid).toSet();

      final List<UserModel> fetchedDosens = [];
      for (var dUid in dosenUids) {
        try {
          final d = await _userService.fetchUserByUid(dUid);
          fetchedDosens.add(d);
        } catch (e) {
          debugPrint("Gagal fetch dosen $dUid: $e");
        }
      }

      final Map<String, UserModel> dosenMap = { 
        for (var d in fetchedDosens) d.uid: d 
      };

      List<DashboardScheduleHelper> tempList = [];
      for (var ajuan in rawList) {
        final dosennya = dosenMap[ajuan.dosenUid];
        
        if (dosennya != null) {
          tempList.add(DashboardScheduleHelper(
            ajuan: ajuan,
            dosen: dosennya
          ));
        }
      }

      _jadwalList = _applyFilterAndSort(tempList);

    } catch (e) {
      debugPrint("Error processing wrapper: $e");
      _jadwalList = [];
    }
  }

  void _filterJadwalTime() {
    if (_currentUser?.dosenUid != null) {
       loadDashboardData(); 
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  List<DashboardScheduleHelper> _applyFilterAndSort(List<DashboardScheduleHelper> list) {
    final now = DateTime.now();

    var filtered = list.where((helper) {
      DateTime? waktuSelesai = _hitungEstimasiSelesai(
        helper.ajuan.tanggalBimbingan, 
        helper.ajuan.waktuBimbingan
      );

      if (waktuSelesai == null) return true;
      return now.isBefore(waktuSelesai);
    }).toList();

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
      return waktuMulai.add(Duration(minutes: _defaultDurationMinutes));
    } catch (e) {
      return null;
    }
  }
}