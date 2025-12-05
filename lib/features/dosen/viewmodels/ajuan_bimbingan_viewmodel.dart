// lib/viewmodels/dosen_ajuan_bimbingan_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';

// services
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';

// models
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';

// =================================================================
// MODEL HELPER (Untuk Tampilan UI)
// =================================================================
class AjuanWithMahasiswa {
  final String ajuanUid;
  final String mahasiswaUid;

  // Data Mahasiswa
  final String namaMahasiswa;
  final String placement;
  
  // Data Ajuan
  final String judulTopik;
  final String metodeBimbingan;
  final DateTime tanggalBimbingan;
  final String waktuBimbingan;
  final DateTime waktuDiajukan;
  final AjuanStatus status;

  AjuanWithMahasiswa({
    required this.ajuanUid,
    required this.mahasiswaUid,
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
  final LogBimbinganService _logService = LogBimbinganService();
  final UserService _userService = UserService();

  late final String dosenUid;

  StreamSubscription<List<AjuanBimbinganModel>>? _subscription;

  DosenAjuanBimbinganViewModel() {
    dosenUid = AuthUtils.currentUid ?? '';
    if (dosenUid.isNotEmpty) {
      _loadAjuanProses();
    } else {
      _error = 'User belum login';
      _isLoading = false;
    }
  }

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
  // LOAD DATA (status: proses)
  // =================================================================
  void _loadAjuanProses() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _ajuanService.getAjuanByDosenUid(dosenUid).listen(
      (List<AjuanBimbinganModel> data) async {
        try {
          if (data.isEmpty) {
            _daftarAjuan = [];
            _isLoading = false;
            _error = null;
            notifyListeners();
            return;
          }

          // --- LOGIKA MAPPING USER (Optimal) ---
          
          // 1. Kumpulkan semua UID Mahasiswa unik
          final mahasiswaUids = data.map((e) => e.mahasiswaUid).toSet();

          // 2. Fetch data user secara paralel
          final List<UserModel> fetchedUsers = await Future.wait(
            mahasiswaUids.map((uid) => _userService.fetchUserByUid(uid)),
          );

          // 3. Buat Dictionary/Map biar pencarian cepat
          final Map<String, UserModel> mahasiswaMap = {
            for (var user in fetchedUsers) user.uid: user
          };

          // 4. Gabungkan Data Ajuan + Data Mahasiswa
          final List<AjuanWithMahasiswa> combinedData = [];

          for (var ajuan in data) {
            final mahasiswa = mahasiswaMap[ajuan.mahasiswaUid];
            
            combinedData.add(
              AjuanWithMahasiswa(
                ajuanUid: ajuan.ajuanUid,
                mahasiswaUid: ajuan.mahasiswaUid,
                namaMahasiswa: mahasiswa?.name ?? "Mahasiswa Tidak Dikenal",
                placement: mahasiswa?.placement ?? "-",
                judulTopik: ajuan.judulTopik,
                metodeBimbingan: ajuan.metodeBimbingan,
                tanggalBimbingan: ajuan.tanggalBimbingan,
                waktuBimbingan: ajuan.waktuBimbingan,
                waktuDiajukan: ajuan.waktuDiajukan,
                status: ajuan.status,
              ),
            );
          }

          // 5. Sorting (Terbaru di atas)
          combinedData.sort((a, b) => b.waktuDiajukan.compareTo(a.waktuDiajukan));

          _daftarAjuan = combinedData;
          _isLoading = false;
          _error = null;
          notifyListeners();

        } catch (e) {
          _error = 'Gagal memproses data ajuan: $e';
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (e) {
        _error = 'Gagal memuat stream ajuan: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // =================================================================
  // ACTION: SETUJUI
  // =================================================================
  Future<void> setujui(String ajuanUid) async {
    try {
      // Cari detail ajuan dari list lokal untuk mendapatkan mahasiswaUid
      final ajuanTarget = _daftarAjuan.firstWhere(
        (element) => element.ajuanUid == ajuanUid,
        orElse: () => throw Exception("Data tidak ditemukan"),
      );

      // 1. Generate ID Log baru
      final String newLogUid = FirebaseFirestore.instance.collection('log_bimbingan').doc().id;

      // 2. Buat objek Log Bimbingan (Draft awal)
      final newLog = LogBimbinganModel(
        logBimbinganUid: newLogUid,
        ajuanUid: ajuanUid,
        mahasiswaUid: ajuanTarget.mahasiswaUid,
        dosenUid: dosenUid,
        ringkasanHasil: '',
        status: LogBimbinganStatus.draft,
        waktuPengajuan: DateTime.now(),
        catatanDosen: null,
        lampiranUrl: null,
      );

      // 3. Update Status Ajuan -> Disetujui
      await _ajuanService.updateAjuanStatus(
        ajuanUid: ajuanUid,
        status: AjuanStatus.disetujui,
      );

      // 4. Simpan Log Bimbingan
      await _logService.saveLogBimbingan(newLog);

    } catch (e) {
      _error = 'Gagal menyetujui ajuan: $e';
      notifyListeners();
    }
  }

  // =================================================================
  // ACTION: TOLAK
  // =================================================================
  Future<void> tolak(String ajuanUid, String keterangan) async {
    if (keterangan.trim().isEmpty) {
      _error = 'Keterangan penolakan wajib diisi';
      notifyListeners();
      return;
    }

    try {
      // Update Status Ajuan -> Ditolak
      await _ajuanService.updateAjuanStatus(
        ajuanUid: ajuanUid,
        status: AjuanStatus.ditolak,
        keterangan: keterangan.trim(),
      );
      
    } catch (e) {
      _error = 'Gagal menolak ajuan: $e';
      notifyListeners();
    }
  }

  // =================================================================
  // UTILS
  // =================================================================
  void refresh() => _loadAjuanProses();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}