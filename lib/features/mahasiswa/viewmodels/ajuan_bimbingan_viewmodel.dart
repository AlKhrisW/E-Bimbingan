import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class MahasiswaAjuanBimbinganViewModel extends ChangeNotifier {
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final NotificationService _notifService = NotificationService();
  final UserService _userService = UserService();

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

  // =================================================================
  // GETTERS (Filtered List)
  // =================================================================

  List<MahasiswaAjuanHelper> get filteredAjuans {
    if (_activeFilter == null) {
      return _allAjuans;
    }
    return _allAjuans.where((item) => item.ajuan.status == _activeFilter).toList();
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

  Future<void> loadAjuanData() async {
    final uid = AuthUtils.currentUid;
    if (uid == null) {
      _errorMessage = "Sesi anda telah berakhir. Silakan login kembali.";
      notifyListeners();
      return;
    }

    final mahasiswa = await _userService.fetchUserByUid(uid);

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil Raw Data Ajuan Bimbingan
      final List<AjuanBimbinganModel> rawAjuans = 
          await _ajuanService.getAjuanByMahasiswaUid(uid, mahasiswa.dosenUid!);

      if (rawAjuans.isEmpty) {
        _allAjuans = [];
      } else {
        // 2. Kumpulkan ID Dosen Unik
        final Set<String> dosenUids = rawAjuans.map((e) => e.dosenUid).toSet();
        
        // 3. Fetch Data Dosen secara Paralel
        final List<UserModel?> fetchedDosens = await Future.wait(
          dosenUids.map((id) => _userService.fetchUserByUid(id))
        );

        // 4. Buat Map Dosen agar akses cepat (O(1))
        final Map<String, UserModel> dosenMap = {
          for (var dosen in fetchedDosens) 
            if (dosen != null) dosen.uid: dosen
        };

        // 5. Gabungkan Data ke Helper (Wrapping)
        final List<MahasiswaAjuanHelper> combinedData = [];

        for (var ajuan in rawAjuans) {
          final dosen = dosenMap[ajuan.dosenUid];

          if (dosen != null) {
            combinedData.add(
              MahasiswaAjuanHelper(
                ajuan: ajuan, 
                dosen: dosen,
              )
            );
          }
        }

        // 6. Sorting (Terbaru di atas)
        combinedData.sort((a, b) => 
            b.ajuan.waktuDiajukan.compareTo(a.ajuan.waktuDiajukan));

        _allAjuans = combinedData;
      }
    } catch (e) {
      _errorMessage = "Gagal memuat riwayat ajuan: $e";
      _allAjuans = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(AjuanStatus? status) {
    _activeFilter = status;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadAjuanData();
  }

  // =================================================================
  // ACTION: SUBMIT AJUAN
  // =================================================================

  // =================================================================
  // ACTION: SUBMIT AJUAN (DIPERBARUI)
  // =================================================================

  Future<bool> submitAjuan({
    required String judulTopik,
    required String metodeBimbingan,
    required String waktuBimbingan,
    required DateTime tanggalBimbingan,
  }) async {
    final uid = AuthUtils.currentUid;
    if (uid == null) {
      _errorMessage = "Sesi berakhir.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ambil User Profile 
      final currentUser = await _userService.fetchUserByUid(uid);
      final String? dosenUidTarget = currentUser.dosenUid;

      // 2. Validasi Dosen
      if (dosenUidTarget == null || dosenUidTarget.isEmpty) {
        throw Exception("Anda belum memiliki Dosen Pembimbing.");
      }

      // 3. Generate ID Baru
      final newId = FirebaseFirestore.instance.collection('ajuan_bimbingan').doc().id;

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
        body: "${currentUser.name} mengajukan bimbingan untuk tanggal $dateStr.",
        type: "ajuan_masuk",
        relatedId: newId,
      );

      // 6. Reload Data
      await loadAjuanData();
      return true;

    } catch (e) {
      _errorMessage = "Gagal mengirim ajuan: $e";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================================================================
  // NEW: FETCH SINGLE DETAIL (Untuk Notifikasi)
  // =================================================================
  
  /// Mengambil data lengkap (Ajuan + Dosen) berdasarkan ID Ajuan.
  Future<MahasiswaAjuanHelper?> getAjuanDetail(String ajuanUid) async {
    try {
      // 1. Ambil data Ajuan by ID
      final AjuanBimbinganModel? ajuan = await _ajuanService.getAjuanByUid(ajuanUid);
      
      if (ajuan == null) return null;

      // 2. Ambil data Dosen berdasarkan dosenUid yang ada di ajuan
      final dosen = await _userService.fetchUserByUid(ajuan.dosenUid);

      // 3. Return wrapper MahasiswaHelper
      return MahasiswaAjuanHelper(
        ajuan: ajuan,
        dosen: dosen,
      );
    } catch (e) {
      debugPrint("Error fetching detail for notification: $e");
      return null;
    }
  }
}
