import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Tambahkan untuk @visibleForTesting

// Utils
import 'package:ebimbingan/core/utils/auth_utils.dart';

// Models
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_ajuan.dart';

// Services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/notification_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

// Definisikan tipe untuk ID generator
typedef String IdGenerator();

class MahasiswaAjuanBimbinganViewModel extends ChangeNotifier {
  // Field Services diubah menjadi final
  final AjuanBimbinganService _ajuanService;
  final NotificationService _notifService;
  final UserService _userService;
  final AuthUtils _authUtils;
  final IdGenerator _idGenerator;

  // Constructor Default (untuk kode aplikasi normal)
  MahasiswaAjuanBimbinganViewModel()
    : _ajuanService = AjuanBimbinganService(),
      _notifService = NotificationService(),
      _userService = UserService(),
      _authUtils = AuthUtils(),
      // Default ID generator menggunakan Firebase
      _idGenerator = (() =>
          FirebaseFirestore.instance.collection('ajuan_bimbingan').doc().id);

  // Constructor Internal (untuk unit test)
  @visibleForTesting
  MahasiswaAjuanBimbinganViewModel.internal({
    required AjuanBimbinganService ajuanService,
    required NotificationService notifService,
    required UserService userService,
    required AuthUtils authUtils,
    required IdGenerator idGenerator, // DI untuk ID generator
  }) : _ajuanService = ajuanService,
       _notifService = notifService,
       _userService = userService,
       _authUtils = authUtils,
       _idGenerator = idGenerator;

  // =================================================================
  // STATE
  // =================================================================

  List<MahasiswaAjuanHelper> _allAjuans = [];

  // State filter untuk widget Filter
  AjuanStatus? _activeFilter;
  AjuanStatus? get activeFilter => _activeFilter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearData() {
    _allAjuans = [];
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

  List<MahasiswaAjuanHelper> get filteredAjuans {
    if (_activeFilter == null) {
      return _allAjuans;
    }
    return _allAjuans
        .where((item) => item.ajuan.status == _activeFilter)
        .toList();
  }

  // =================================================================
  // HELPER: GET DOSEN NAME
  // =================================================================

  Future<String> getDosenNameForCurrentUser() async {
    final uid = _authUtils.currentUid; // Menggunakan DI
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

  Future<void> loadAjuanData() async {
    final uid = _authUtils.currentUid; // Menggunakan DI
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
      // 1. Ambil Raw Data Ajuan Bimbingan
      final List<AjuanBimbinganModel> rawAjuans = await _ajuanService
          .getAjuanByMahasiswaUid(uid, mahasiswa.dosenUid!);

      if (rawAjuans.isEmpty) {
        _allAjuans = [];
      } else {
        // 2. Kumpulkan ID Dosen Unik
        final Set<String> dosenUids = rawAjuans.map((e) => e.dosenUid).toSet();

        // 3. Fetch Data Dosen secara Paralel
        final List<UserModel?> fetchedDosens = await Future.wait(
          dosenUids.map((id) => _userService.fetchUserByUid(id)),
        );

        // 4. Buat Map Dosen agar akses cepat (O(1))
        final Map<String, UserModel> dosenMap = {
          for (var dosen in fetchedDosens)
            if (dosen != null) dosen.uid: dosen,
        };

        // 5. Gabungkan Data ke Helper (Wrapping)
        final List<MahasiswaAjuanHelper> combinedData = [];

        for (var ajuan in rawAjuans) {
          final dosen = dosenMap[ajuan.dosenUid];

          if (dosen != null) {
            combinedData.add(MahasiswaAjuanHelper(ajuan: ajuan, dosen: dosen));
          }
        }

        // 6. Sorting (Terbaru di atas)
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

  Future<void> refresh() async {
    await loadAjuanData();
  }

  // =================================================================
  // ACTION: SUBMIT AJUAN
  // =================================================================

  Future<bool> submitAjuan({
    required String judulTopik,
    required String metodeBimbingan,
    required String waktuBimbingan,
    required DateTime tanggalBimbingan,
  }) async {
    final uid = _authUtils.currentUid; // Menggunakan DI
    if (uid == null) {
      _errorMessage = "Sesi berakhir.";
      _safeNotifyListeners();
      return false;
    }

    _isLoading = true;
    _safeNotifyListeners();

    try {
      // 1. Ambil User Profile
      final currentUser = await _userService.fetchUserByUid(uid);
      final String? dosenUidTarget = currentUser.dosenUid;

      // 2. Validasi Dosen
      if (dosenUidTarget == null || dosenUidTarget.isEmpty) {
        throw Exception("Anda belum memiliki Dosen Pembimbing.");
      }

      // 3. Generate ID Baru (Menggunakan ID Generator yang dapat di-mock)
      final newId = _idGenerator();

      // 4. Buat Model
      final newAjuan = AjuanBimbinganModel(
        ajuanUid: newId,
        mahasiswaUid: uid,
        dosenUid: dosenUidTarget,
        judulTopik: judulTopik,
        metodeBimbingan: metodeBimbingan,
        waktuBimbingan: waktuBimbingan,
        tanggalBimbingan: tanggalBimbingan,
        status: AjuanStatus.proses,
        waktuDiajukan: DateTime.now(),
        keterangan: null,
      );

      // 5. Simpan via Service
      await _ajuanService.saveAjuan(newAjuan);

      // --- [BARU] KIRIM NOTIFIKASI KE DOSEN ---
      final dateStr = DateFormat('dd MMM').format(tanggalBimbingan);
      await _notifService.sendNotification(
        recipientUid: dosenUidTarget,
        title: "Ajuan Bimbingan Baru",
        body:
            "${currentUser.name} mengajukan bimbingan untuk tanggal $dateStr.",
        type: "ajuan_masuk",
        relatedId: newId,
      );

      // 6. Reload Data
      await loadAjuanData();
      return true;
    } catch (e) {
      _errorMessage = "Gagal mengirim ajuan: $e";
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

  /// Mengambil data lengkap (Ajuan + Dosen) berdasarkan ID Ajuan.
  Future<MahasiswaAjuanHelper?> getAjuanDetail(String ajuanUid) async {
    try {
      // 1. Ambil data Ajuan by ID
      final AjuanBimbinganModel? ajuan = await _ajuanService.getAjuanByUid(
        ajuanUid,
      );

      if (ajuan == null) return null;

      // 2. Ambil data Dosen berdasarkan dosenUid yang ada di ajuan
      final dosen = await _userService.fetchUserByUid(ajuan.dosenUid);

      // 3. Return wrapper MahasiswaHelper
      return MahasiswaAjuanHelper(ajuan: ajuan, dosen: dosen);
    } catch (e) {
      debugPrint("Error fetching detail for notification: $e");
      return null;
    }
  }
}
