// lib/viewmodels/ajuan_bimbingan_dosen_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';

class DosenAjuanBimbinganViewModel extends ChangeNotifier {
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final UserService _userService = UserService();

  late final String dosenUid;

  DosenAjuanBimbinganViewModel() {
    dosenUid = AuthUtils.currentUid ?? '';

    print('DEBUG: Dosen UID yang sedang login: $dosenUid');
    print('DEBUG: Memuat ajuan untuk UID: $dosenUid');

    if (dosenUid.isEmpty) {
      _error = 'User belum login';
      _isLoading = false;
    } else {
      _loadAjuan();
    }
  }

  // =================================================================
  // State
  // =================================================================
  List<AjuanBimbinganModel> _ajuan = [];
  List<AjuanBimbinganModel> get ajuan => _ajuan;

  List<AjuanBimbinganModel> get proses =>
      _ajuan.where((a) => a.status == AjuanStatus.proses).toList();

  List<AjuanBimbinganModel> get disetujui =>
      _ajuan.where((a) => a.status == AjuanStatus.disetujui).toList();

  List<AjuanBimbinganModel> get ditolak =>
      _ajuan.where((a) => a.status == AjuanStatus.ditolak).toList();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription<List<AjuanBimbinganModel>>? _subscription;

  // =================================================================
  // Load ajuan real-time
  // =================================================================
  void _loadAjuan() {
    _subscription?.cancel();
    _subscription = _ajuanService.getAjuanByDosenUid(dosenUid).listen(
      (data) {
        _ajuan = data
          ..sort((a, b) => b.waktuDiajukan.compareTo(a.waktuDiajukan));
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Gagal memuat ajuan: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // =================================================================
  // Ambil data mahasiswa (untuk FutureBuilder di UI)
  // =================================================================
  Future<UserModel> getMahasiswa(String mahasiswaUid) =>
      _userService.fetchUserByUid(mahasiswaUid);

  // =================================================================
  // Aksi dosen
  // =================================================================
  Future<void> setujui(String ajuanUid) async {
    await _ajuanService.updateAjuanStatus(
      ajuanUid: ajuanUid,
      status: AjuanStatus.disetujui,
    );
  }

  Future<void> tolak(String ajuanUid, String keterangan) async {
    if (keterangan.trim().isEmpty) {
      _error = 'Keterangan penolakan harus diisi';
      notifyListeners();
      return;
    }
    await _ajuanService.updateAjuanStatus(
      ajuanUid: ajuanUid,
      status: AjuanStatus.ditolak,
      keterangan: keterangan.trim(),
    );
  }

  // =================================================================
  // Refresh & Cleanup
  // =================================================================
  void refresh() => _loadAjuan();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}