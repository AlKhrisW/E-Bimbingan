import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

// Utils
import 'package:ebimbingan/core/utils/auth_utils.dart';

// Models
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_harian.dart';

// Services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/notification_service.dart';
import 'package:ebimbingan/data/services/logbook_harian_service.dart';

class MahasiswaLogHarianViewModel extends ChangeNotifier {
  final LogbookHarianService _logbookService = LogbookHarianService();
  final NotificationService _notifService = NotificationService();
  final UserService _userService = UserService();

  // =================================================================
  // STATE
  // =================================================================

  List<MahasiswaHarianHelper> _logbookList = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LogbookStatus? _activeFilter;
  LogbookStatus? get activeFilter => _activeFilter;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearData() {
    _logbookList = [];
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
  // GETTERS
  // =================================================================

  List<MahasiswaHarianHelper> get logbooks {
    if (_activeFilter == null) {
      return _logbookList;
    }
    return _logbookList
        .where((item) => item.logbook.status == _activeFilter)
        .toList();
  }

  // =================================================================
  // HELPER: GET DOSEN NAME
  // =================================================================

  Future<String> getDosenNameForCurrentUser() async {
    final uid = AuthUtils.currentUid;
    if (uid == null) return "Sesi berakhir";

    try {
      final mahasiswa = await _userService.fetchUserByUid(uid);
      
      if (mahasiswa.dosenUid == null || mahasiswa.dosenUid!.isEmpty) {
        return "Belum memiliki Dosen Pembimbing";
      }

      final dosen = await _userService.fetchUserByUid(mahasiswa.dosenUid!);
      return dosen.name;

    } catch (e) {
      return "Gagal memuat info dosen";
    }
  }

  // =================================================================
  // LOAD DATA (Batch Fetching Pattern)
  // =================================================================

  Future<void> loadLogbooks() async {
    // 1. Cek Login via AuthUtils
    final uid = AuthUtils.currentUid;
    if (uid == null) {
      _errorMessage = "Sesi anda berakhir. Silakan login kembali.";
      _safeNotifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      // 2. Ambil List Logbook Harian (Raw Data)
      final List<LogbookHarianModel> rawLogs = 
          await _logbookService.getLogbookByMahasiswaUid(uid);

      if (rawLogs.isEmpty) {
        _logbookList = [];
      } else {
        final Set<String> dosenUids = rawLogs.map((e) => e.dosenUid).toSet();

        final List<UserModel?> fetchedDosens = await Future.wait(
          dosenUids.map((id) => _userService.fetchUserByUid(id))
        );

        final Map<String, UserModel> dosenMap = { 
          for (var dosen in fetchedDosens) 
            if (dosen != null) dosen.uid: dosen
        };

        final List<MahasiswaHarianHelper> wrappedList = [];

        for (var log in rawLogs) {
          final dosen = dosenMap[log.dosenUid];

          if (dosen != null) {
            wrappedList.add(
              MahasiswaHarianHelper(
                logbook: log,
                dosen: dosen,
              ),
            );
          }
        }

        wrappedList.sort((a, b) => b.logbook.tanggal.compareTo(a.logbook.tanggal));

        _logbookList = wrappedList;
      }

    } catch (e) {
      _errorMessage = "Gagal memuat logbook: $e";
      _logbookList = [];
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }
  
  void setFilter(LogbookStatus? status) {
    _activeFilter = status;
    _safeNotifyListeners();
  }

  Future<void> refresh() async {
    await loadLogbooks();
  }

  // =================================================================
  // ACTION: TAMBAH LOGBOOK
  // =================================================================

  Future<bool> tambahLogbook({
    required String judulTopik,
    required String deskripsi,
    required DateTime tanggal,
  }) async {
    final uid = AuthUtils.currentUid;
    if (uid == null) {
      _errorMessage = "Sesi berakhir.";
      _safeNotifyListeners();
      return false;
    }

    _isLoading = true;
    _safeNotifyListeners();

    try {
      if (judulTopik.isEmpty || deskripsi.isEmpty) {
        throw Exception("Topik dan Deskripsi wajib diisi.");
      }

      // 1. Ambil Profil Mahasiswa (untuk Nama & Dosen UID)
      final currentUser = await _userService.fetchUserByUid(uid);
      final String? dosenUidTarget = currentUser.dosenUid;

      if (dosenUidTarget == null || dosenUidTarget.isEmpty) {
        throw Exception("Anda belum memiliki Dosen Pembimbing.");
      }

      // 2. Generate ID Unik
      final newId = FirebaseFirestore.instance.collection('logbook_harian').doc().id;

      // 3. Buat Object Model
      final newLog = LogbookHarianModel(
        logbookHarianUid: newId,
        mahasiswaUid: uid,
        dosenUid: dosenUidTarget,
        judulTopik: judulTopik,
        tanggal: tanggal,
        deskripsi: deskripsi,
        status: LogbookStatus.draft,
      );

      // 4. Simpan ke Firestore
      await _logbookService.saveLogbookHarian(newLog);

      // --- [BARU] KIRIM NOTIFIKASI ---
      await _notifService.sendNotification(
        recipientUid: dosenUidTarget,
        title: "Logbook Harian Baru",
        body: "${currentUser.name} menambahkan logbook kegiatan: $judulTopik",
        type: "log_harian_baru",
        relatedId: newId,
      );
      // -------------------------------

      // 5. Reload data agar list terupdate
      await loadLogbooks();
      
      return true;

    } catch (e) {
      _errorMessage = "Gagal menambah logbook: $e";
      _safeNotifyListeners();
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // =================================================================
  // NEW: FETCH SINGLE DETAIL (Untuk Notifikasi)
  // =================================================================

  /// Mengambil data lengkap (Logbook + Dosen) berdasarkan ID Logbook.
  Future<MahasiswaHarianHelper?> getLogbookDetail(String logbookUid) async {
    try {
      // 1. Ambil data Logbook by ID
      final LogbookHarianModel? log = await _logbookService.getLogbookById(logbookUid);
      
      if (log == null) return null;

      // 2. Ambil data Dosen
      final dosen = await _userService.fetchUserByUid(log.dosenUid);

      // 3. Return wrapper
      return MahasiswaHarianHelper(
        logbook: log,
        dosen: dosen,
      );
    } catch (e) {
      debugPrint("Error fetching logbook detail: $e");
      return null;
    }
  }
}