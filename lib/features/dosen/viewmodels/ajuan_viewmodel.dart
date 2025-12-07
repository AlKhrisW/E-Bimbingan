import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/helper_ajuan_bimbingan.dart';
import 'package:ebimbingan/data/services/notification_service.dart';

class DosenAjuanViewModel extends ChangeNotifier {
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

  // =================================================================
  // LOAD DATA
  // =================================================================

  Future<void> _loadAjuanProses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final uid = AuthUtils.currentUid;
    if (uid == null) {
      _error = 'User belum login';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final List<AjuanBimbinganModel> data = await _ajuanService.getAjuanByDosenUid(uid);

      if (data.isEmpty) {
        _daftarAjuan = [];
        _isLoading = false;
        notifyListeners();
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
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================================================================
  // ACTIONS
  // =================================================================

  Future<void> setujui(String ajuanUid) async {
    final uid = AuthUtils.currentUid;
    if (uid == null) return;

    try {
      // 1. Ambil data ajuan yang sedang diproses
      final itemTarget = _daftarAjuan.firstWhere(
        (element) => element.ajuan.ajuanUid == ajuanUid,
        orElse: () => throw Exception("Data tidak ditemukan"),
      );

      final String newLogUid = FirebaseFirestore.instance.collection('log_bimbingan').doc().id;

      // ... (Logika pembuatan LogBimbinganModel tetap sama) ...
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

      // 2. Update status di Database
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

      await _notifService.scheduleReminder(
        id: ajuanUid.hashCode,
        title: "Pengingat Bimbingan Besok",
        body: "Mahasiswa: ${itemTarget.mahasiswa.name} pukul ${itemTarget.ajuan.waktuBimbingan}",
        scheduledDate: itemTarget.ajuan.tanggalBimbingan.subtract(const Duration(days: 1)),
      );

      // Refresh list
      await _loadAjuanProses();

    } catch (e) {
      _error = 'Gagal menyetujui ajuan: $e';
      notifyListeners();
    }
  }

  Future<void> tolak(String ajuanUid, String keterangan) async {
    if (keterangan.trim().isEmpty) {
      _error = 'Keterangan penolakan wajib diisi';
      notifyListeners();
      return;
    }

    try {
       // Ambil data untuk tahu siapa mahasiswanya
      final itemTarget = _daftarAjuan.firstWhere(
        (element) => element.ajuan.ajuanUid == ajuanUid,
      );

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

      await _loadAjuanProses();
    } catch (e) {
      _error = 'Gagal menolak ajuan: $e';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadAjuanProses();
  }
}