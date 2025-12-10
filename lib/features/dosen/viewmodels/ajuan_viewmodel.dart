import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class DosenAjuanViewModel extends ChangeNotifier {
  // --- DEPENDENCIES ---
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final LogBimbinganService _logService = LogBimbinganService();
  final UserService _userService = UserService();
  final NotificationService _notifService = NotificationService();

  DosenAjuanViewModel();

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
  // LOAD DATA UTAMA (List Ajuan)
  // =================================================================

  Future<void> _loadAjuanProses() async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    final uid = AuthUtils.currentUid;
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
      final AjuanBimbinganModel? ajuan = await _ajuanService.getAjuanByUid(ajuanUid);
      
      if (ajuan == null) return null;

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
    final uid = AuthUtils.currentUid;
    if (uid == null) return;

    try {
      AjuanWithMahasiswa? itemTarget;
      
      try {
        itemTarget = _daftarAjuan.firstWhere((element) => element.ajuan.ajuanUid == ajuanUid);
      } catch (_) {
        itemTarget = await getAjuanDetail(ajuanUid);
      }

      if (itemTarget == null) throw Exception("Data ajuan tidak ditemukan");

      final String newLogUid = FirebaseFirestore.instance.collection('log_bimbingan').doc().id;

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

      await _ajuanService.updateAjuanStatus(
        ajuanUid: ajuanUid,
        status: AjuanStatus.disetujui,
      );

      await _logService.saveLogBimbingan(newLog);

      await _notifService.sendNotification(
        recipientUid: itemTarget.ajuan.mahasiswaUid,
        title: "Ajuan Bimbingan Disetujui",
        body: "Dosen menyetujui jadwal untuk ${DateFormat('dd MMM').format(itemTarget.ajuan.tanggalBimbingan)}.",
        type: "ajuan_status", 
        relatedId: ajuanUid,
      );

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

      await _ajuanService.updateAjuanStatus(
        ajuanUid: ajuanUid,
        status: AjuanStatus.ditolak,
        keterangan: keterangan.trim(),
      );

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