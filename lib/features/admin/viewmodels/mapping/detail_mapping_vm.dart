import 'package:flutter/material.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../data/services/user_service.dart';

class DetailMappingViewModel with ChangeNotifier {
  // --- service ---
  final UserService _userService = UserService();

  // --- state ---
  List<UserModel> _mappedMahasiswa = [];
  List<UserModel> _unassignedMahasiswa = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // --- getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<UserModel> get mappedMahasiswa => _mappedMahasiswa;
  List<UserModel> get unassignedMahasiswa => _unassignedMahasiswa;

  // --- private helpers ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setMessage({String? error, String? success}) {
    _errorMessage = error;
    _successMessage = success;
    notifyListeners();
  }

  void resetMessages() {
    _setMessage(error: null, success: null);
  }

  // --- actions ---

  /// Memuat daftar mahasiswa yang dibimbing oleh dosenUid tertentu
  Future<void> loadMappedMahasiswa(String dosenUid) async {
    _setLoading(true);
    resetMessages();

    try {
      _mappedMahasiswa =
          await _userService.fetchMahasiswaByDosenUid(dosenUid);
    } catch (e) {
      _setMessage(
          error: 'Gagal memuat mahasiswa bimbingan: ${e.toString()}');
      _mappedMahasiswa = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Memuat daftar mahasiswa yang belum ter-mapping (untuk modal tambah)
  Future<void> loadUnassignedMahasiswa() async {
    try {
      _unassignedMahasiswa =
          await _userService.fetchMahasiswaUnassigned();
    } catch (e) {
      _setMessage(
          error:
              'Gagal memuat daftar mahasiswa yang belum ter-mapping: ${e.toString()}');
      _unassignedMahasiswa = [];
    }
  }

  /// Menghapus relasi 1 mahasiswa dari dosen (set dosen_uid menjadi null)
  Future<bool> removeMapping(String mahasiswaUid, String dosenUid) async {
    _setLoading(true);
    resetMessages();

    try {
      await _userService.updateUserMetadataPartial(mahasiswaUid, {
        'dosen_uid': null,
      });

      // Hapus dari list lokal
      _mappedMahasiswa.removeWhere((m) => m.uid == mahasiswaUid);

      _setMessage(success: 'Relasi mahasiswa berhasil dihapus.');
      return true;
    } catch (e) {
      _setMessage(error: 'Gagal menghapus relasi: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Menambah relasi mapping untuk list mahasiswa terpilih
  Future<bool> addMapping(
      List<String> mahasiswaUids, String dosenUid) async {
    _setLoading(true);
    resetMessages();

    try {
      await _userService.batchUpdateDosenRelasi(
        mahasiswaUids: mahasiswaUids,
        newDosenUid: dosenUid,
      );

      // Refresh data ter-mapping
      await loadMappedMahasiswa(dosenUid);

      _setMessage(
          success:
              '${mahasiswaUids.length} mahasiswa berhasil ditambahkan ke bimbingan.');
      return true;
    } catch (e) {
      _setMessage(
          error: 'Gagal menambahkan relasi mapping: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}