import 'dart:io';
import 'package:flutter/material.dart';

// Utils
import 'package:ebimbingan/core/utils/auth_utils.dart';

// Models
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_mingguan.dart';

// Services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/notification_service.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

class MahasiswaLogMingguanViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final LogBimbinganService _logService = LogBimbinganService();
  final NotificationService _notifService = NotificationService();
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();

  // =================================================================
  // STATE
  // =================================================================

  List<MahasiswaMingguanHelper> _allLogs = [];
  
  // State filter untuk widget MahasiswaLogFilter
  LogBimbinganStatus? _activeFilter;
  LogBimbinganStatus? get activeFilter => _activeFilter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearData() {
    _allLogs = [];
    _activeFilter = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // =================================================================
  // GETTERS (Filtered List)
  // =================================================================

  List<MahasiswaMingguanHelper> get filteredLogs {
    if (_activeFilter == null) {
      return _allLogs;
    }
    return _allLogs.where((item) => item.log.status == _activeFilter).toList();
  }

  // =================================================================
  // LOAD DATA
  // =================================================================

  Future<void> loadLogData() async {
    final uid = AuthUtils().currentUid;
    if (uid == null) {
      _errorMessage = "Sesi anda telah berakhir. Silakan login kembali.";
      _safeNotifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      // 1. Ambil Log Bimbingan
      final List<LogBimbinganModel> logs = 
          await _logService.getLogBimbinganByMahasiswaUid(uid);

      if (logs.isEmpty) {
        _allLogs = [];
      } else {
        // 2. Kumpulkan ID Unik untuk Ajuan & Dosen
        final Set<String> ajuanUids = logs.map((e) => e.ajuanUid).toSet();
        final Set<String> dosenUids = logs.map((e) => e.dosenUid).toSet();
        
        // 3. Fetch Data secara Paralel (Ajuan + Dosen)
        final results = await Future.wait([
          // Fetch Ajuans
          Future.wait(ajuanUids.map((id) => _ajuanService.getAjuanByUid(id))),
          // Fetch Dosens
          Future.wait(dosenUids.map((id) => _userService.fetchUserByUid(id))),
        ]);

        // 4. Casting hasil fetch
        final List<AjuanBimbinganModel?> fetchedAjuans = results[0] as List<AjuanBimbinganModel?>;
        final List<UserModel?> fetchedDosens = results[1] as List<UserModel?>;

        // 5. Buat Map untuk akses cepat (O(1))
        final Map<String, AjuanBimbinganModel> ajuanMap = {
          for (var ajuan in fetchedAjuans) 
            if (ajuan != null) ajuan.ajuanUid: ajuan
        };

        final Map<String, UserModel> dosenMap = {
          for (var dosen in fetchedDosens) 
            if (dosen != null) dosen.uid: dosen
        };

        // 6. Gabungkan Data ke Helper
        final List<MahasiswaMingguanHelper> combinedData = [];

        for (var log in logs) {
          final ajuan = ajuanMap[log.ajuanUid];
          final dosen = dosenMap[log.dosenUid];

          if (ajuan != null && dosen != null) {
            combinedData.add(
              MahasiswaMingguanHelper(
                log: log, 
                ajuan: ajuan,
                dosen: dosen,
              )
            );
          }
        }

        // 7. Sorting
        combinedData.sort((a, b) {
          int priority(LogBimbinganStatus s) {
            if (s == LogBimbinganStatus.draft) return 0;
            if (s == LogBimbinganStatus.rejected) return 1;
            if (s == LogBimbinganStatus.pending) return 2;
            return 3; 
          }
          int compare = priority(a.log.status).compareTo(priority(b.log.status));
          if (compare != 0) return compare;
          return b.log.waktuPengajuan.compareTo(a.log.waktuPengajuan);
        });

        _allLogs = combinedData;
      }
    } catch (e) {
      _errorMessage = "Gagal memuat logbook: $e";
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setFilter(LogBimbinganStatus? status) {
    _activeFilter = status;
    _safeNotifyListeners();
  }

  Future<void> refresh() async {
    await loadLogData();
  }

  // =================================================================
  // ACTION: SUBMIT
  // =================================================================

  Future<bool> submitDraftOrRevisi({
    required String logUid,
    required String ringkasanBaru,
    File? lampiranBaru,
  }) async {
    final uid = AuthUtils().currentUid; 
    _isLoading = true;
    _safeNotifyListeners();

    try {
      // 1. Simpan Update ke Database
      await _logService.updateLogBimbinganMahasiswa(
        logBimbinganUid: logUid,
        ringkasanHasil: ringkasanBaru,
        status: LogBimbinganStatus.pending,
        waktuPengajuan: DateTime.now(),
        fileFoto: lampiranBaru,
      );

      // --- [BARU] LOGIKA NOTIFIKASI ---
      
      // A. Ambil Data Log untuk tahu siapa Dosennya
      final logData = await _logService.getLogBimbinganByUid(logUid);
      
      if (logData != null && uid != null) {
        // B. Ambil Nama Mahasiswa
        final currentUser = await _userService.fetchUserByUid(uid);
        
        // C. Kirim Notif ke Dosen
        await _notifService.sendNotification(
          recipientUid: logData.dosenUid,
          title: "Log Bimbingan Diisi",
          body: "${currentUser.name} telah mengisi hasil bimbingan. Mohon diperiksa.",
          type: "log_mingguan_update",
          relatedId: logUid,
        );
      }

      await loadLogData();
      return true;

    } catch (e) {
      _errorMessage = "Gagal mengirim logbook: $e";
      _safeNotifyListeners();
      return false;
    }
  }

  // =================================================================
  // NEW: FETCH SINGLE DETAIL (Untuk Notifikasi)
  // =================================================================

  /// Mengambil data lengkap (Log + Ajuan + Dosen) berdasarkan ID Log Mingguan.
  Future<MahasiswaMingguanHelper?> getLogbookDetail(String logUid) async {
    try {
      // 1. Ambil data Log Mingguan by ID
      final LogBimbinganModel? log = await _logService.getLogBimbinganByUid(logUid);
      if (log == null) return null;

      // 2. Ambil data Ajuan (Parent dari log ini)
      final AjuanBimbinganModel? ajuan = await _ajuanService.getAjuanByUid(log.ajuanUid);
      if (ajuan == null) return null;

      // 3. Ambil data Dosen
      final UserModel? dosen = await _userService.fetchUserByUid(log.dosenUid);
      if (dosen == null) return null;

      // 4. Return wrapper
      return MahasiswaMingguanHelper(
        log: log,
        ajuan: ajuan,
        dosen: dosen,
      );
    } catch (e) {
      debugPrint("Error fetching mingguan detail: $e");
      return null;
    }
  }
}