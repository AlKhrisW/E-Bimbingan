// File: features/mahasiswa/viewmodels/mahasiswa_ajuan_bimbingan_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_ajuan.dart';
// Tambahan Import Model Log
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';

import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/notification_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
// Tambahan Import Service Log
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';

typedef String IdGenerator();

class MahasiswaAjuanBimbinganViewModel extends ChangeNotifier {
  // Services (final – dependency injection)
  final AjuanBimbinganService _ajuanService;
  final NotificationService _notifService;
  final UserService _userService;
  // Service baru untuk cek status log
  final LogBimbinganService _logService; 
  final AuthUtils _authUtils;
  final IdGenerator _idGenerator;

  // Constructor Default
  MahasiswaAjuanBimbinganViewModel()
    : _ajuanService = AjuanBimbinganService(),
      _notifService = NotificationService(),
      _userService = UserService(),
      // Inisialisasi service log
      _logService = LogBimbinganService(),
      _authUtils = AuthUtils(),
      _idGenerator = (() =>
          FirebaseFirestore.instance.collection('ajuan_bimbingan').doc().id);

  // Constructor Internal (untuk unit test)
  @visibleForTesting
  MahasiswaAjuanBimbinganViewModel.internal({
    required AjuanBimbinganService ajuanService,
    required NotificationService notifService,
    required UserService userService,
    // Tambahkan parameter logService
    required LogBimbinganService logService, 
    required AuthUtils authUtils,
    required IdGenerator idGenerator,
  }) : _ajuanService = ajuanService,
       _notifService = notifService,
       _userService = userService,
       _logService = logService,
       _authUtils = authUtils,
       _idGenerator = idGenerator;

  // =================================================================
  // STATE
  // =================================================================
  List<MahasiswaAjuanHelper> _allAjuans = [];

  AjuanStatus? _activeFilter;
  AjuanStatus? get activeFilter => _activeFilter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error lama (untuk SnackBar / fallback)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // NEW: Error khusus per field (untuk ditampilkan merah di atas field)
  String? _topikError;
  String? _metodeError;
  String? _generalError;

  String? get topikError => _topikError;
  String? get metodeError => _metodeError;
  String? get generalError => _generalError;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  void clearData() {
    _allAjuans = [];
    _activeFilter = null;
    _isLoading = false;
    _errorMessage = null;
    _topikError = null;
    _metodeError = null;
    _generalError = null;
    notifyListeners();
  }

  // =================================================================
  // GETTERS (Filtered List)
  // =================================================================
  List<MahasiswaAjuanHelper> get filteredAjuans {
    if (_activeFilter == null) return _allAjuans;
    return _allAjuans
        .where((item) => item.ajuan.status == _activeFilter)
        .toList();
  }
  
  // =================================================================
  // MELAKUKAN PENGECEKAN UNTUK MEMBUAT AJUAN BARU
  // =================================================================
  Future<String?> checkUntukAjuanBaru() async {
    final uid = _authUtils.currentUid;
    if (uid == null) return "Sesi berakhir.";

    _isLoading = true;
    _safeNotifyListeners();

    try {
      // Mengambil status dari log terakhir mahasiswa
      final lastStatus = await _logService.getLogStatusTerbaru(uid);

      // Jika belum pernah membuat log sama sekali, berarti boleh lanjut
      if (lastStatus == null) {
        return null; 
      }

      // Jika status log terakhir BUKAN 'approved' tidak bisa buat ajuan baru
      if (lastStatus != LogBimbinganStatus.approved) {
        return "Anda belum bisa mengajukan bimbingan baru karena Log Mingguan terakhir statusnya belum disetujui (Approved). Harap selesaikan terlebih dahulu.";
      }

      // Jika Approved, lolos
      return null;
    } catch (e) {
      return "Gagal memvalidasi status log: $e";
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // =================================================================
  // HELPER: GET DOSEN NAME
  // =================================================================
  Future<String> getDosenNameForCurrentUser() async {
    final uid = _authUtils.currentUid;
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
  // LOAD DATA
  // =================================================================
  Future<void> loadAjuanData() async {
    final uid = _authUtils.currentUid;
    if (uid == null) {
      _errorMessage = "Sesi anda telah berakhir. Silakan login kembali.";
      _safeNotifyListeners();
      return;
    }

    final mahasiswa = await _userService.fetchUserByUid(uid);
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final List<AjuanBimbinganModel> rawAjuans = await _ajuanService
          .getAjuanByMahasiswaUid(uid, mahasiswa.dosenUid!);

      if (rawAjuans.isEmpty) {
        _allAjuans = [];
      } else {
        final Set<String> dosenUids = rawAjuans.map((e) => e.dosenUid).toSet();

        final List<UserModel?> fetchedDosens = await Future.wait(
          dosenUids.map((id) => _userService.fetchUserByUid(id)),
        );

        final Map<String, UserModel> dosenMap = {
          for (var dosen in fetchedDosens)
            if (dosen != null) dosen.uid: dosen,
        };

        final List<MahasiswaAjuanHelper> combinedData = [];
        for (var ajuan in rawAjuans) {
          final dosen = dosenMap[ajuan.dosenUid];
          if (dosen != null) {
            combinedData.add(MahasiswaAjuanHelper(ajuan: ajuan, dosen: dosen));
          }
        }

        combinedData.sort(
          (a, b) => b.ajuan.waktuDiajukan.compareTo(a.ajuan.waktuDiajukan),
        );
        _allAjuans = combinedData;
      }
    } catch (e) {
      _errorMessage = "Gagal memuat riwayat ajuan: $e";
      _allAjuans = [];
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setFilter(AjuanStatus? status) {
    _activeFilter = status;
    _safeNotifyListeners();
  }

  Future<void> refresh() async => await loadAjuanData();

  // =================================================================
  // SUBMIT AJUAN – DENGAN VALIDASI PER FIELD
  // =================================================================
  Future<bool> submitAjuan({
    required String judulTopik,
    required String metodeBimbingan,
    required String waktuBimbingan,
    required DateTime tanggalBimbingan,
  }) async {
    // Reset semua error dulu
    _errorMessage = null;
    _topikError = null;
    _metodeError = null;
    _generalError = null;

    final uid = _authUtils.currentUid;
    if (uid == null) {
      _errorMessage = "Sesi berakhir. Silakan login kembali.";
      _generalError = _errorMessage;
      _safeNotifyListeners();
      return false;
    }

    final String topikClean = judulTopik.trim();
    final String metodeClean = metodeBimbingan.trim();

    // Validasi Topik
    if (topikClean.isEmpty) {
      _topikError = "Topik wajib diisi.";
    } else if (topikClean.length < 5) {
      _topikError = "Topik minimal 5 karakter.";
    } else if (topikClean.length > 255) {
      _topikError = "Topik maksimal 255 karakter.";
    } else if (!RegExp(r"^[a-zA-Z0-9\s.,\-/():]+$").hasMatch(topikClean)) {
      _topikError =
          "Topik mengandung karakter tidak diizinkan. Hanya huruf, angka, spasi, dan tanda baca umum (.,-/) yang diperbolehkan.";
    }

    // Validasi Metode
    if (metodeClean.isEmpty) {
      _metodeError = "Metode wajib diisi.";
    } else if (metodeClean.length > 100) {
      _metodeError = "Metode maksimal 100 karakter.";
    } else if (!RegExp(r"^[a-zA-Z0-9\s.,\-/()]+$").hasMatch(metodeClean)) {
      _metodeError = "Metode mengandung karakter tidak diizinkan.";
    }

    // Jika ada error di field → stop proses dan tampilkan error merah
    if (_topikError != null || _metodeError != null) {
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }

    _isLoading = true;
    _safeNotifyListeners();

    try {
      final currentUser = await _userService.fetchUserByUid(uid);
      final String? dosenUidTarget = currentUser.dosenUid;

      if (dosenUidTarget == null || dosenUidTarget.isEmpty) {
        _generalError = "Anda belum memiliki Dosen Pembimbing.";
        _isLoading = false;
        _safeNotifyListeners();
        return false;
      }

      final newId = _idGenerator();

      final newAjuan = AjuanBimbinganModel(
        ajuanUid: newId,
        mahasiswaUid: uid,
        dosenUid: dosenUidTarget,
        judulTopik: topikClean,
        metodeBimbingan: metodeClean,
        waktuBimbingan: waktuBimbingan,
        tanggalBimbingan: tanggalBimbingan,
        status: AjuanStatus.proses,
        waktuDiajukan: DateTime.now(),
        keterangan: null,
      );

      await _ajuanService.saveAjuan(newAjuan);

      final dateStr = DateFormat('dd MMM').format(tanggalBimbingan);
      await _notifService.sendNotification(
        recipientUid: dosenUidTarget,
        title: "Ajuan Bimbingan Baru",
        body:
            "${currentUser.name} mengajukan bimbingan untuk tanggal $dateStr.",
        type: "ajuan_masuk",
        relatedId: newId,
      );

      await loadAjuanData();
      return true;
    } catch (e) {
      _errorMessage = "Gagal mengirim ajuan: $e";
      _generalError = _errorMessage;
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // =================================================================
  // FETCH SINGLE DETAIL (untuk notifikasi)
  // =================================================================
  Future<MahasiswaAjuanHelper?> getAjuanDetail(String ajuanUid) async {
    try {
      final AjuanBimbinganModel? ajuan = await _ajuanService.getAjuanByUid(
        ajuanUid,
      );
      if (ajuan == null) return null;
      final dosen = await _userService.fetchUserByUid(ajuan.dosenUid);
      return MahasiswaAjuanHelper(ajuan: ajuan, dosen: dosen);
    } catch (e) {
      debugPrint("Error fetching detail for notification: $e");
      return null;
    }
  }
}