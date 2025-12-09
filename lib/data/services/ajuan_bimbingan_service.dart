import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ajuan_bimbingan_model.dart';

class AjuanBimbinganService {
  final CollectionReference _ajuanCollection = 
      FirebaseFirestore.instance.collection('ajuan_bimbingan');

  // =================================================================
  // CREATE & UPDATE
  // =================================================================

  Future<void> saveAjuan(AjuanBimbinganModel ajuan) async {
    try {
      await _ajuanCollection.doc(ajuan.ajuanUid).set(ajuan.toMap());
    } catch (e) {
      throw Exception('gagal menyimpan ajuan bimbingan: ${e.toString()}');
    }
  }

  Future<void> updateAjuanStatus({
    required String ajuanUid,
    required AjuanStatus status,
    String? keterangan,
  }) async {
    try {
      await _ajuanCollection.doc(ajuanUid).update({
        'status': status.toString().split('.').last,
        'keterangan': keterangan,
      });
    } catch (e) {
      throw Exception('gagal memperbarui status ajuan: ${e.toString()}');
    }
  }

  // =================================================================
  // READ (FUTURE / GET)
  // =================================================================

  Future<List<AjuanBimbinganModel>> getAjuanByDosenUid(String dosenUid) async {
    try {
      final snapshot = await _ajuanCollection
          .where('dosenUid', isEqualTo: dosenUid)
          .where('status', isEqualTo: 'proses')
          .orderBy('waktuDiajukan', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return AjuanBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('gagal mengambil data ajuan dosen: ${e.toString()}');
    }
  }

  Future<List<AjuanBimbinganModel>> getAjuanByMahasiswaUid(String mahasiswaUid, String dosenUid) async {
    try {
      final snapshot = await _ajuanCollection
          .where('mahasiswaUid', isEqualTo: mahasiswaUid)
          .where('dosenUid', isEqualTo: dosenUid)
          .orderBy('waktuDiajukan', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return AjuanBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('gagal mengambil data ajuan mahasiswa: ${e.toString()}');
    }
  }

  Future<List<AjuanBimbinganModel>> getRiwayatSpesifik(String dosenUid, String mahasiswaUid) async {
    try {
      final snapshot = await _ajuanCollection
          .where('dosenUid', isEqualTo: dosenUid)
          .where('mahasiswaUid', isEqualTo: mahasiswaUid)
          .orderBy('waktuDiajukan', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return AjuanBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('gagal mengambil riwayat spesifik: ${e.toString()}');
    }
  }

  Future<AjuanBimbinganModel?> getAjuanByUid(String ajuanUid) async {
    try {
      final doc = await _ajuanCollection.doc(ajuanUid).get();
      
      if (doc.exists) {
        return AjuanBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // =================================================================
  // DELETE
  // =================================================================

  Future<void> deleteAjuan(String ajuanUid) async {
    try {
      await _ajuanCollection.doc(ajuanUid).delete();
    } catch (e) {
      throw Exception('gagal menghapus ajuan: ${e.toString()}');
    }
  }
}