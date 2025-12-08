import 'dart:io';
import 'package:flutter/material.dart';

// Utils
import 'package:ebimbingan/core/utils/auth_utils.dart';

// Models
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_mingguan.dart';

// Services
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

class MahasiswaLogMingguanViewModel extends ChangeNotifier {
  final LogBimbinganService _logService = LogBimbinganService();
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
    final uid = AuthUtils.currentUid;
    if (uid == null) {
      _errorMessage = "Sesi anda telah berakhir. Silakan login kembali.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil semua Log milik Mahasiswa
      final List<LogBimbinganModel> logs = 
          await _logService.getLogBimbinganByMahasiswaUid(uid);

      if (logs.isEmpty) {
        _allLogs = [];
      } else {
        // 2. Kumpulkan Ajuan UID yang unik
        final Set<String> ajuanUids = logs.map((e) => e.ajuanUid).toSet();
        
        // 3. Fetch data Ajuan secara paralel (Batch Fetch)
        final List<AjuanBimbinganModel?> fetchedAjuans = await Future.wait(
          ajuanUids.map((id) => _ajuanService.getAjuanByUid(id))
        );

        // 4. Buat Map untuk pencarian cepat (Logika sama persis dengan Dosen VM)
        final Map<String, AjuanBimbinganModel> ajuanMap = {
          for (var ajuan in fetchedAjuans) 
            if (ajuan != null) ajuan.ajuanUid: ajuan
        };

        // 5. Gabungkan Log dengan Ajuan (Helper Factory)
        final List<MahasiswaMingguanHelper> combinedData = [];

        for (var log in logs) {
          // Cari ajuan yang sesuai dengan log ini di dalam Map
          final ajuan = ajuanMap[log.ajuanUid];

          // Jika ajuan ditemukan, masukkan ke list helper
          // (Data yang tidak lengkap/corrupt tidak akan ditampilkan agar aman)
          if (ajuan != null) {
            combinedData.add(
              MahasiswaMingguanHelper(
                log: log, 
                ajuan: ajuan // Input sekarang Single Object, bukan Map lagi
              )
            );
          }
        }

        // 6. Sorting: Prioritas Draft & Revisi di atas
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
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(LogBimbinganStatus? status) {
    _activeFilter = status;
    notifyListeners();
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
    _isLoading = true;
    notifyListeners();

    try {
      await _logService.updateLogBimbinganMahasiswa(
        logBimbinganUid: logUid,
        ringkasanHasil: ringkasanBaru,
        status: LogBimbinganStatus.pending,
        waktuPengajuan: DateTime.now(),
        fileFoto: lampiranBaru,
      );

      await loadLogData();
      return true;

    } catch (e) {
      _errorMessage = "Gagal mengirim logbook: $e";
      notifyListeners();
      return false;
    }
  }
}