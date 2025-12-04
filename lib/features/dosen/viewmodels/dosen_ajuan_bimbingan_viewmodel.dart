import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';


// =================================================================
// MODEL HELPER
// =================================================================
class AjuanWithMahasiswa {
  final String ajuanUid;

  // Mahasiswa
  final String namaMahasiswa;
  final String placement;

  // Ajuan
  final String judulTopik;
  final String metodeBimbingan;
  final DateTime tanggalBimbingan;
  final String waktuBimbingan;
  final DateTime waktuDiajukan;
  final AjuanStatus status;

  AjuanWithMahasiswa({
    required this.ajuanUid,
    required this.namaMahasiswa,
    required this.placement,
    required this.judulTopik,
    required this.metodeBimbingan,
    required this.tanggalBimbingan,
    required this.waktuBimbingan,
    required this.waktuDiajukan,
    required this.status,
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
  // STATE
  // =================================================================

  List<AjuanWithMahasiswa> _ajuanWithMahasiswa = [];
  List<AjuanWithMahasiswa> get ajuanWithMahasiswa => _ajuanWithMahasiswa;

  List<AjuanWithMahasiswa> get proses =>
      _ajuanWithMahasiswa.where((a) => a.status == AjuanStatus.proses).toList();

  List<AjuanWithMahasiswa> get disetujui =>
      _ajuanWithMahasiswa.where((a) => a.status == AjuanStatus.disetujui).toList();

  List<AjuanWithMahasiswa> get ditolak =>
      _ajuanWithMahasiswa.where((a) => a.status == AjuanStatus.ditolak).toList();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription<List<AjuanBimbinganModel>>? _subscription;


  // =================================================================
  // LOAD DATA (REALTIME + MAPPING KE UI MODEL)
  // =================================================================
  void _loadAjuan() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _ajuanService.getAjuanByDosenUid(dosenUid).listen(
      (List<AjuanBimbinganModel> data) async {
        try {
          if (data.isEmpty) {
            _ajuanWithMahasiswa = [];
            _isLoading = false;
            _error = null;
            notifyListeners();
            return;
          }

          // 1. Ambil UID mahasiswa unik
          final mahasiswaUids = data.map((e) => e.mahasiswaUid).toSet();

          // 2. Fetch semua mahasiswa secara paralel
          final List<UserModel> fetchedUsers = await Future.wait(
            mahasiswaUids.map((uid) => _userService.fetchUserByUid(uid)),
          );

          // 3. Buat map UID -> UserModel
          final Map<String, UserModel> mahasiswaMap = {
            for (var user in fetchedUsers) user.uid: user
          };

          // 4. Mapping ke UI Model
          final List<AjuanWithMahasiswa> combinedData = [];

          for (var ajuan in data) {
            final mahasiswa = mahasiswaMap[ajuan.mahasiswaUid];
            if (mahasiswa != null) {
              combinedData.add(
                AjuanWithMahasiswa(
                  ajuanUid: ajuan.ajuanUid,
                  namaMahasiswa: mahasiswa.name,
                  placement: mahasiswa.placement ?? "-",
                  judulTopik: ajuan.judulTopik,
                  metodeBimbingan: ajuan.metodeBimbingan,
                  tanggalBimbingan: ajuan.tanggalBimbingan,
                  waktuBimbingan: ajuan.waktuBimbingan,
                  waktuDiajukan: ajuan.waktuDiajukan,
                  status: ajuan.status,
                ),
              );
            }
          }

          // 5. Sorting terbaru di atas
          combinedData.sort(
            (a, b) => b.waktuDiajukan.compareTo(a.waktuDiajukan),
          );

          _ajuanWithMahasiswa = combinedData;
          _isLoading = false;
          _error = null;
          notifyListeners();
        } catch (e) {
          _error = 'Gagal memuat ajuan: $e';
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (e) {
        _error = 'Gagal memuat ajuan: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // =================================================================
  // AKSI DOSEN
  // =================================================================
  Future<void> setujui(String ajuanUid) async {
    try {
      await _ajuanService.updateAjuanStatus(
        ajuanUid: ajuanUid,
        status: AjuanStatus.disetujui,
      );
    } catch (e) {
      _error = 'Gagal menyetujui ajuan';
      notifyListeners();
    }
  }

  Future<void> tolak(String ajuanUid, String keterangan) async {
    if (keterangan.trim().isEmpty) {
      _error = 'Keterangan penolakan harus diisi';
      notifyListeners();
      return;
    }

    try {
      await _ajuanService.updateAjuanStatus(
        ajuanUid: ajuanUid,
        status: AjuanStatus.ditolak,
        keterangan: keterangan.trim(),
      );
    } catch (e) {
      _error = 'Gagal menolak ajuan';
      notifyListeners();
    }
  }

  // =================================================================
  // REFRESH & CLEANUP
  // =================================================================
  void refresh() => _loadAjuan();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
