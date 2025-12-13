import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Tambahkan untuk @visibleForTesting

// Utils
import 'package:ebimbingan/core/utils/auth_utils.dart';

// Services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/data/services/notification_service.dart';

// Models
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/dosen_helper_ajuan.dart';

// Definisikan tipe untuk ID generator (untuk mock ID Log Bimbingan)
typedef String LogIdGenerator(); // 🔥 BARU

class DosenAjuanViewModel extends ChangeNotifier {
  // --- DEPENDENCIES (Diubah menjadi final) ---
  final AjuanBimbinganService _ajuanService;
  final LogBimbinganService _logService;
  final UserService _userService;
  final NotificationService _notifService;
  final AuthUtils _authUtils; // 🔥 BARU
  final LogIdGenerator _logIdGenerator; // 🔥 BARU

  // Constructor Default (Untuk penggunaan aplikasi normal)
  DosenAjuanViewModel()
      : _ajuanService = AjuanBimbinganService(),
        _logService = LogBimbinganService(),
        _userService = UserService(),
        _notifService = NotificationService(),
        _authUtils = AuthUtils(), // 🔥 Inisialisasi AuthUtils default
        _logIdGenerator = (() =>
            FirebaseFirestore.instance.collection('log_bimbingan').doc().id);

  // Constructor Internal (Untuk Unit Test) 🔥 BARU
  @visibleForTesting
  DosenAjuanViewModel.internal({
    required AjuanBimbinganService ajuanService,
    required LogBimbinganService logService,
    required UserService userService,
    required NotificationService notifService,
    required AuthUtils authUtils,
    required LogIdGenerator logIdGenerator,
  })  : _ajuanService = ajuanService,
        _logService = logService,
        _userService = userService,
        _notifService = notifService,
        _authUtils = authUtils,
        _logIdGenerator = logIdGenerator;

  // =================================================================
  // STATE
  // =================================================================

  List<AjuanWithMahasiswa> _daftarAjuan = [];
  List<AjuanWithMahasiswa> get daftarAjuan => _daftarAjuan;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearData() {
    _daftarAjuan = [];
    _isLoading = false;
    _error = null;
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
  // GETTERS MINGGUAN COUNT
  // =================================================================
  
  Stream<QuerySnapshot> get ajuanStream {
    final uid = AuthUtils().currentUid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _ajuanService.getMingguanCountByDosen(uid);
  }

  /// Stream khusus untuk menghitung jumlah ajuan yang belum diverifikasi (badge)
  Stream<int> get unreadCountStream {
    return ajuanStream.map((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Cek field 'status' sebagai String
        final String? status = data['status']; 
        
        // Hitung jika statusnya 'proses'
        if (status == 'proses') {
          count++;
        }
      }
      return count;
    });
  }

  // =================================================================
  // LOAD DATA UTAMA (List Ajuan)
  // =================================================================

  Future<void> _loadAjuanProses() async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    // 🔥 Gunakan AuthUtils yang diinjeksikan
    final uid = _authUtils.currentUid;
    if (uid == null) {
      _error = 'User belum login';
      _isLoading = false;
      _safeNotifyListeners();
      return;
    }

    try {
      final List<AjuanBimbinganModel> data = await _ajuanService.getAjuanByDosenUid(uid);

      if (data.isEmpty) {
        _daftarAjuan = [];
        _isLoading = false;
        _safeNotifyListeners();
        return;
      }

      final mahasiswaUids = data.map((e) => e.mahasiswaUid).toSet();

      // 🔥 Gunakan UserService yang diinjeksikan
      final List<UserModel> fetchedUsers = await Future.wait(
        mahasiswaUids.map((uid) => _userService.fetchUserByUid(uid)),
      );

      final Map<String, UserModel> userMap = {
        for (var user in fetchedUsers) user.uid: user
      };

      final List<AjuanWithMahasiswa> combinedData = [];

      for (var ajuan in data) {
        final mahasiswa = userMap[ajuan.mahasiswaUid];
        
        if (mahasiswa != null) {
          combinedData.add(
            AjuanWithMahasiswa(
              ajuan: ajuan,
              mahasiswa: mahasiswa,
            ),
          );
        }
      }

      combinedData.sort((a, b) => b.ajuan.waktuDiajukan.compareTo(a.ajuan.waktuDiajukan));
      _daftarAjuan = combinedData;

    } catch (e) {
      _error = 'Gagal memproses daftar ajuan: $e';
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // =================================================================
  // FETCH SINGLE DETAIL (Untuk Notifikasi)
  // =================================================================
  
  Future<AjuanWithMahasiswa?> getAjuanDetail(String ajuanUid) async {
    try {
      // 🔥 Gunakan AjuanService yang diinjeksikan
      final AjuanBimbinganModel? ajuan = await _ajuanService.getAjuanByUid(ajuanUid);
      
      if (ajuan == null) return null;

      // 🔥 Gunakan UserService yang diinjeksikan
      final mahasiswa = await _userService.fetchUserByUid(ajuan.mahasiswaUid);

      return AjuanWithMahasiswa(
        ajuan: ajuan,
        mahasiswa: mahasiswa,
      );
    } catch (e) {
      debugPrint("Error fetching detail for notification: $e");
      return null;
    }
  }

  // =================================================================
  // ACTIONS: SETUJUI & TOLAK
  // =================================================================

  Future<void> setujui(String ajuanUid) async {
    // 🔥 Gunakan AuthUtils yang diinjeksikan
    final uid = _authUtils.currentUid;
    if (uid == null) return;

    try {
      AjuanWithMahasiswa? itemTarget;
      
      try {
        // Coba cari di list lokal dulu (jika list sudah dimuat)
        itemTarget = _daftarAjuan.firstWhere((element) => element.ajuan.ajuanUid == ajuanUid);
      } catch (_) {
        // Jika tidak ada di list lokal (misal, datang dari notifikasi), fetch detailnya
        itemTarget = await getAjuanDetail(ajuanUid);
      }

      if (itemTarget == null) throw Exception("Data ajuan tidak ditemukan");

      // 🔥 Gunakan LogIdGenerator yang diinjeksikan
      final String newLogUid = _logIdGenerator();

        final newLog = LogBimbinganModel(
          logBimbinganUid: newLogUid,
          ajuanUid: ajuanUid,
          mahasiswaUid: itemTarget.ajuan.mahasiswaUid,
          dosenUid: uid, 
          ringkasanHasil: '',
          status: LogBimbinganStatus.draft,
          waktuPengajuan: DateTime.now(),
          catatanDosen: null,
          lampiranUrl: null,
        );

      // 🔥 Gunakan AjuanService yang diinjeksikan
      await _ajuanService.updateAjuanStatus(
        ajuanUid: ajuanUid,
        status: AjuanStatus.disetujui,
      );

      // 🔥 Gunakan LogService yang diinjeksikan
      await _logService.saveLogBimbingan(newLog);

      // 🔥 Gunakan NotifService yang diinjeksikan
      await _notifService.sendNotification(
        recipientUid: itemTarget.ajuan.mahasiswaUid,
        title: "Ajuan Bimbingan Disetujui",
        body: "Dosen menyetujui jadwal untuk ${DateFormat('dd MMM').format(itemTarget.ajuan.tanggalBimbingan)}.",
        type: "ajuan_status", 
        relatedId: ajuanUid,
      );

      // Refresh list jika list sedang dibuka
      if (_daftarAjuan.isNotEmpty) {
        await _loadAjuanProses();
      }

    } catch (e) {
      _error = 'Gagal menyetujui ajuan: $e';
      _safeNotifyListeners();
      rethrow; 
    }
  }

  Future<void> tolak(String ajuanUid, String keterangan) async {
    if (keterangan.trim().isEmpty) {
      _error = 'Keterangan penolakan wajib diisi';
      _safeNotifyListeners();
      return;
    }

    try {
      AjuanWithMahasiswa? itemTarget;
      try {
        itemTarget = _daftarAjuan.firstWhere((element) => element.ajuan.ajuanUid == ajuanUid);
      } catch (_) {
        itemTarget = await getAjuanDetail(ajuanUid);
      }

      if (itemTarget == null) throw Exception("Data ajuan tidak ditemukan");

      // 🔥 Gunakan AjuanService yang diinjeksikan
      await _ajuanService.updateAjuanStatus(
        ajuanUid: ajuanUid,
        status: AjuanStatus.ditolak,
        keterangan: keterangan.trim(),
      );

      // 🔥 Gunakan NotifService yang diinjeksikan
      await _notifService.sendNotification(
        recipientUid: itemTarget.ajuan.mahasiswaUid,
        title: "Ajuan Bimbingan Ditolak",
        body: "Maaf, ajuan ditolak. Ket: $keterangan",
        type: "ajuan_status",
        relatedId: ajuanUid,
      );

      if (_daftarAjuan.isNotEmpty) {
        await _loadAjuanProses();
      }
    } catch (e) {
      _error = 'Gagal menolak ajuan: $e';
      _safeNotifyListeners();
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _loadAjuanProses();
  }
}