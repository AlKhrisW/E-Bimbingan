import 'dart:async';
import 'package:flutter/material.dart';

// Utils & Models
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/dosen_helper_dashboard.dart';

// Import Model & Service Log
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/data/services/logbook_harian_service.dart'; //
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';   //

// =================================================================
// HELPER CLASS: DATA PROGRESS MAHASISWA
// =================================================================
class DosenStudentProgressHelper {
  final UserModel mahasiswa;
  final int totalDays;
  final int totalWeeks;
  final int logbookFilled;
  final int bimbinganFilled;

  DosenStudentProgressHelper({
    required this.mahasiswa,
    required this.totalDays,
    required this.totalWeeks,
    required this.logbookFilled,
    required this.bimbinganFilled,
  });

  // Getter Persentase Logbook (0.0 - 1.0)
  double get logbookPercent {
    if (totalDays == 0) return 0.0;
    double p = logbookFilled / totalDays;
    return p > 1.0 ? 1.0 : p;
  }

  // Getter Persentase Bimbingan (0.0 - 1.0)
  double get bimbinganPercent {
    if (totalWeeks == 0) return 0.0;
    double p = bimbinganFilled / totalWeeks;
    return p > 1.0 ? 1.0 : p;
  }
}

// =================================================================
// VIEW MODEL DOSEN DASHBOARD
// =================================================================
class DosenDashboardViewModel extends ChangeNotifier {
  // Services
  final UserService _userService = UserService();
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final LogbookHarianService _logbookService = LogbookHarianService();
  final LogBimbinganService _logBimbinganService = LogBimbinganService();

  // ================================================================
  // STATE
  // ================================================================
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // List Jadwal (Horizontal)
  List<DosenDashboardHelper> _jadwalList = [];
  List<DosenDashboardHelper> get jadwalTampil => _jadwalList;

  // List Progress Mahasiswa (Vertical)
  List<DosenStudentProgressHelper> _studentProgressList = [];
  List<DosenStudentProgressHelper> get studentProgressList => _studentProgressList;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _timer;
  final int _defaultDurationMinutes = 60;

  void clearData() {
    _jadwalList = [];
    _studentProgressList = [];
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
    // Timer berjalan setiap 1 menit untuk cek waktu (agar card jadwal hilang real-time)
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _filterJadwalTime(); 
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =================================================================
  // CORE LOGIC
  // =================================================================

  Future<void> loadDashboardData() async {
    final uid = AuthUtils().currentUid;
    if (uid == null) {
      _errorMessage = "Sesi berakhir.";
      _isLoading = false;
      notifyListeners(); 
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Dosen Profile
      _currentUser = await _userService.fetchUserByUid(uid);

      // 2. Fetch Jadwal (Logika Existing)
      final List<AjuanBimbinganModel> rawJadwal = await _ajuanService.getJadwalDosen(uid);
      await _processWrapping(rawJadwal);

      // 3. Fetch List Mahasiswa & Hitung Progress
      await _fetchStudentsAndCalculateProgress(uid);

    } catch (e) {
      _errorMessage = "Gagal memuat dashboard: $e";
      _jadwalList = [];
      _studentProgressList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------------
  // LOGIC BARU: MENGHITUNG PROGRESS
  // -----------------------------------------------------------------
  Future<void> _fetchStudentsAndCalculateProgress(String dosenUid) async {
    try {
      // A. Ambil semua mahasiswa yang dibimbing dosen ini
      final List<UserModel> students = await _userService.fetchMahasiswaByDosenUid(dosenUid);

      List<DosenStudentProgressHelper> tempProgress = [];

      // B. Loop parallel untuk mempercepat proses
      final futures = students.map((mhs) async {
        
        // 1. Hitung Target (Hari & Minggu)
        int totalDays = 0;
        int totalWeeks = 0;
        if (mhs.startDate != null && mhs.endDate != null) {
          final diff = mhs.endDate!.difference(mhs.startDate!).inDays + 1;
          totalDays = diff > 0 ? diff : 0;
          totalWeeks = (totalDays / 7).truncate();
        }

        // 2. Fetch Data Logbook & Bimbingan
        int filledLogbook = 0;
        int filledBimbingan = 0;

        try {
          // --- LOGBOOK HARIAN ---
          final allLogbooks = await _logbookService.getLogbook(mhs.uid, dosenUid);
          
          // --- LOG BIMBINGAN ---
          final allBimbingans = await _logBimbinganService.getRiwayatSpesifik(dosenUid, mhs.uid);
          
          // 3. FILTER STATUS: Hanya hitung yang Verified / Approved          
          filledLogbook = allLogbooks
              .where((log) => log.status == LogbookStatus.verified)
              .length;

          filledBimbingan = allBimbingans
              .where((log) => log.status == LogBimbinganStatus.approved)
              .length;

        } catch (e) {
          debugPrint("Gagal hitung progress mhs ${mhs.name}: $e");
        }

        return DosenStudentProgressHelper(
          mahasiswa: mhs,
          totalDays: totalDays,
          totalWeeks: totalWeeks,
          logbookFilled: filledLogbook,
          bimbinganFilled: filledBimbingan,
        );
      });

      tempProgress = await Future.wait(futures);

      _studentProgressList = tempProgress;

    } catch (e) {
      debugPrint("Gagal load student progress: $e");
    }
  }

  // -----------------------------------------------------------------
  // LOGIC JADWAL (EXISTING)
  // -----------------------------------------------------------------
  Future<void> _processWrapping(List<AjuanBimbinganModel> rawList) async {
    if (rawList.isEmpty) { _jadwalList = []; return; }
    try {
      final Set<String> mhsUids = rawList.map((e) => e.mahasiswaUid).toSet();
      final List<UserModel> fetchedMhs = [];
      for (var uid in mhsUids) {
        try {
          final m = await _userService.fetchUserByUid(uid);
          fetchedMhs.add(m);
        } catch (e) { }
      }
      final Map<String, UserModel> mhsMap = { for (var m in fetchedMhs) m.uid: m };
      List<DosenDashboardHelper> tempList = [];
      for (var ajuan in rawList) {
        final mahasiswa = mhsMap[ajuan.mahasiswaUid];
        if (mahasiswa != null) {
          tempList.add(DosenDashboardHelper(ajuan: ajuan, mahasiswa: mahasiswa));
        }
      }
      _jadwalList = _applyFilterAndSort(tempList);
    } catch (e) { _jadwalList = []; }
  }

  void _filterJadwalTime() { if (_currentUser != null) loadDashboardData(); else _timer?.cancel(); }
  
  List<DosenDashboardHelper> _applyFilterAndSort(List<DosenDashboardHelper> list) {
    final now = DateTime.now();
    var filtered = list.where((helper) {
      DateTime? waktuSelesai = _hitungEstimasiSelesai(helper.ajuan.tanggalBimbingan, helper.ajuan.waktuBimbingan);
      if (waktuSelesai == null) return true; 
      return now.isBefore(waktuSelesai);
    }).toList();
    filtered.sort((a, b) {
      int compareDate = a.ajuan.tanggalBimbingan.compareTo(b.ajuan.tanggalBimbingan);
      if (compareDate == 0) return a.ajuan.waktuBimbingan.compareTo(b.ajuan.waktuBimbingan);
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
      return DateTime(tanggal.year, tanggal.month, tanggal.day, jam, menit).add(Duration(minutes: _defaultDurationMinutes));
    } catch (e) { return null; }
  }
}