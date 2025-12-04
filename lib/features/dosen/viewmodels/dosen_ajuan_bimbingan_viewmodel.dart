// lib/viewmodels/ajuan_bimbingan_dosen_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';

// --- Model Pembantu ---
class AjuanWithMahasiswa {
  final AjuanBimbinganModel ajuan;
  final UserModel mahasiswa;

  AjuanWithMahasiswa({
    required this.ajuan,
    required this.mahasiswa,
  });
}

class DosenAjuanBimbinganViewModel extends ChangeNotifier {
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final UserService _userService = UserService();

  late final String dosenUid;

  DosenAjuanBimbinganViewModel() {
    dosenUid = AuthUtils.currentUid ?? '';
    if (dosenUid.isEmpty) {
      _error = 'User belum login';
      _isLoading = false;
    } else {
      _loadAjuan();
    }
  }

  // =================================================================
  // State BARU
  // =================================================================
  List<AjuanWithMahasiswa> _ajuanWithMahasiswa = [];
  List<AjuanWithMahasiswa> get ajuanWithMahasiswa => _ajuanWithMahasiswa;

  // Getter yang disesuaikan untuk model baru
  List<AjuanWithMahasiswa> get proses =>
      _ajuanWithMahasiswa.where((a) => a.ajuan.status == AjuanStatus.proses).toList();

  List<AjuanWithMahasiswa> get disetujui =>
      _ajuanWithMahasiswa.where((a) => a.ajuan.status == AjuanStatus.disetujui).toList();

  List<AjuanWithMahasiswa> get ditolak =>
      _ajuanWithMahasiswa.where((a) => a.ajuan.status == AjuanStatus.ditolak).toList();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription<List<AjuanBimbinganModel>>? _subscription;

  // =================================================================
  // Load ajuan real-time (Logika Diperbarui)
  // =================================================================
  void _loadAjuan() {
    _subscription?.cancel();
    _subscription = _ajuanService.getAjuanByDosenUid(dosenUid).listen(
      (data) async {
        if (data.isEmpty) {
          _ajuanWithMahasiswa = [];
          _isLoading = false;
          _error = null;
          notifyListeners();
          return;
        }

        // 1. Ambil semua UID mahasiswa yang unik
        final mahasiswaUids = data.map((e) => e.mahasiswaUid).toSet();

        // 2. Ambil detail semua mahasiswa secara bersamaan
        // Menggunakan Future.wait untuk performa yang lebih baik
        final List<Future<UserModel>> fetchFutures = mahasiswaUids
            .map((uid) => _userService.fetchUserByUid(uid))
            .toList();

        final List<UserModel> fetchedUsers = await Future.wait(fetchFutures);

        // 3. Buat map untuk akses cepat (UID -> UserModel)
        final Map<String, UserModel> mahasiswaMap = {
          for (var user in fetchedUsers) user.uid: user
        };

        // 4. Gabungkan Ajuan dengan data Mahasiswa
        final List<AjuanWithMahasiswa> combinedData = [];
        for (var ajuan in data) {
          final mahasiswa = mahasiswaMap[ajuan.mahasiswaUid];
          if (mahasiswa != null) {
            combinedData.add(AjuanWithMahasiswa(
              ajuan: ajuan,
              mahasiswa: mahasiswa,
            ));
          }
        }
        
        // 5. Update State
        _ajuanWithMahasiswa = combinedData
          ..sort((a, b) => b.ajuan.waktuDiajukan.compareTo(a.ajuan.waktuDiajukan));
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
  // Aksi dosen (Tidak perlu diubah, karena bekerja pada ajuanUid)
  // =================================================================
  Future<void> setujui(String ajuanUid) async {
    // ... sama seperti sebelumnya
    await _ajuanService.updateAjuanStatus(
      ajuanUid: ajuanUid,
      status: AjuanStatus.disetujui,
    );
  }

  Future<void> tolak(String ajuanUid, String keterangan) async {
    // ... sama seperti sebelumnya
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