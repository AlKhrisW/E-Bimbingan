import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../data/models/ajuan_bimbingan_model.dart';
import '../../../data/models/user_model.dart';

class AjuanBimbinganViewModel extends ChangeNotifier {
  bool isLoading = false;

  /// =====================================================
  /// SUBMIT AJUAN BIMBINGAN
  /// return null jika sukses
  /// return pesan error jika gagal
  /// =====================================================
  Future<String?> submitAjuan({
    required UserModel user,
    required String judulTopik,
    required String metode,
    required String waktu,
    required DateTime tanggal,
  }) async {
    try {
      // -----------------------------------------------------
      // VALIDASI: apakah mahasiswa memiliki dosen pembimbing?
      // -----------------------------------------------------
      if (user.dosenUid == null || user.dosenUid!.isEmpty) {
        return "Mahasiswa belum memiliki dosen pembimbing.";
      }

      isLoading = true;
      notifyListeners();

      // -----------------------------------------------------
      // SIAPKAN MODEL AJUAN
      // -----------------------------------------------------
      final newAjuan = AjuanBimbinganModel(
        ajuanUid: "", // nanti diisi docRef.id
        mahasiswaUid: user.uid ?? "",
        dosenUid: user.dosenUid ?? "",
        judulTopik: judulTopik,
        metodeBimbingan: metode,
        waktuBimbingan: waktu,
        tanggalBimbingan: tanggal,
        status: AjuanStatus.proses,
        waktuDiajukan: DateTime.now(),
        keterangan: null,
      );

      // -----------------------------------------------------
      // SIMPAN KE FIRESTORE
      // -----------------------------------------------------
      final docRef = await FirebaseFirestore.instance
          .collection("ajuan_bimbingan")
          .add(newAjuan.toMap());

      // update UID di dokumen
      await docRef.update({"ajuanUid": docRef.id});

      isLoading = false;
      notifyListeners();

      return null; // sukses
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Gagal mengirim ajuan: $e";
    }
  }

  /// =====================================================
  /// LOAD NAMA DOSEN
  /// =====================================================
  Future<String> loadDosenName(String dosenUid) async {
    try {
      if (dosenUid.isEmpty) return "Tidak ada dosen pembimbing";

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(dosenUid)
          .get();

      if (!doc.exists) return "Dosen tidak ditemukan";

      final data = doc.data()!;
      return data['name'] ??
          data['nama'] ??
          data['full_name'] ??
          "Nama dosen tidak tersedia";
    } catch (e) {
      return "Gagal memuat nama dosen";
    }
  }

  /// =====================================================
  /// GET RIWAYAT AJUAN MAHASISWA (Stream)
  /// =====================================================
  Stream<List<AjuanBimbinganModel>> getRiwayat(String mahasiswaUid) {
    return FirebaseFirestore.instance
        .collection("ajuan_bimbingan")
        .where("mahasiswaUid", isEqualTo: mahasiswaUid)
        .snapshots()
        .map((snap) {
          final List<AjuanBimbinganModel> list = [];
          
          for (final doc in snap.docs) {
            try {
              final data = Map<String, dynamic>.from(doc.data());
              data['ajuanUid'] = data['ajuanUid'] ?? doc.id;
              list.add(AjuanBimbinganModel.fromMap(data));
            } catch (e) {
              continue;
            }
          }
          
          // Sort manual di memory
          list.sort((a, b) {
            if (a.tanggalBimbingan == null) return 1;
            if (b.tanggalBimbingan == null) return -1;
            return b.tanggalBimbingan!.compareTo(a.tanggalBimbingan!);
          });
          
          return list;
        });
  }

  /// =====================================================
  /// GET DETAIL AJUAN BY ID (Future)
  /// untuk detail screen
  /// =====================================================
  Future<AjuanBimbinganModel?> getDetailAjuan(String ajuanUid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("ajuan_bimbingan")
          .doc(ajuanUid)
          .get();

      if (!doc.exists) return null;

      final data = Map<String, dynamic>.from(doc.data()!);
      data['ajuanUid'] = data['ajuanUid'] ?? doc.id;
      
      return AjuanBimbinganModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  /// =====================================================
  /// GET DETAIL AJUAN STREAM (Real-time)
  /// untuk detail screen dengan real-time update
  /// =====================================================
  Stream<AjuanBimbinganModel?> getDetailAjuanStream(String ajuanUid) {
    return FirebaseFirestore.instance
        .collection("ajuan_bimbingan")
        .doc(ajuanUid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;

          final data = Map<String, dynamic>.from(doc.data()!);
          data['ajuanUid'] = data['ajuanUid'] ?? doc.id;
          
          return AjuanBimbinganModel.fromMap(data);
        });
  }
}