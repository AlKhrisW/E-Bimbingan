import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ajuan_bimbingan_model.dart';

class AjuanBimbinganService {
  // inisialisasi collection reference
  final CollectionReference _ajuanCollection = 
      FirebaseFirestore.instance.collection('ajuan_bimbingan');

  // ----------------------------------------------------------------------
  // create & update (c/u)
  // ----------------------------------------------------------------------

  /// menyimpan ajuan bimbingan baru atau memperbarui yang sudah ada
  Future<void> saveAjuan(AjuanBimbinganModel ajuan) async {
    try {
      // menggunakan .set() dengan uid memastikan dokumen baru atau update
      await _ajuanCollection.doc(ajuan.ajuanUid).set(ajuan.toMap());
    } catch (e) {
      throw Exception('gagal menyimpan ajuan bimbingan: ${e.toString()}');
    }
  }

  /// memperbarui status ajuan oleh dosen (setuju/tolak)
  Future<void> updateAjuanStatus({
    required String ajuanUid,
    required AjuanStatus status,
    String? keterangan,
  }) async {
    try {
      await _ajuanCollection.doc(ajuanUid).update({
        'status': status.toString().split('.').last, // simpan sebagai string lowercase
        'keterangan': keterangan,
      });
    } catch (e) {
      throw Exception('gagal memperbarui status ajuan: ${e.toString()}');
    }
  }

  // ----------------------------------------------------------------------
  // read (r)
  // ----------------------------------------------------------------------

  /// mengambil semua ajuan bimbingan untuk dosen tertentu
  Stream<List<AjuanBimbinganModel>> getAjuanByDosenUid(String dosenUid) {
    // dosen melihat ajuan yang statusnya masih 'proses' atau yang sudah disetujui/ditolak
    return _ajuanCollection
        .where('dosenUid', isEqualTo: dosenUid)
        .where('status', whereIn: ['proses']) // hanya ajuan yang masih proses
        .orderBy('waktuDiajukan', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AjuanBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    });
  }

  /// mengambil semua ajuan bimbingan milik mahasiswa tertentu
  Stream<List<AjuanBimbinganModel>> getAjuanByMahasiswaUid(String mahasiswaUid) {
    return _ajuanCollection
        .where('mahasiswaUid', isEqualTo: mahasiswaUid)
        .orderBy('waktuDiajukan', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AjuanBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    });
  }

  /// mengambil riwayat ajuan bimbingan untuk dosen dan mahasiswa tertentu
  Stream<List<AjuanBimbinganModel>> getRiwayatSpesifik(String dosenUid, String mahasiswaUid) {
    return _ajuanCollection
        .where('dosenUid', isEqualTo: dosenUid)
        .where('mahasiswaUid', isEqualTo: mahasiswaUid)
        .orderBy('waktuDiajukan', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AjuanBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    });
  }

  // ----------------------------------------------------------------------
  // delete (d)
  // ----------------------------------------------------------------------

  /// menghapus ajuan bimbingan
  Future<void> deleteAjuan(String ajuanUid) async {
    try {
      await _ajuanCollection.doc(ajuanUid).delete();
    } catch (e) {
      throw Exception('gagal menghapus ajuan: ${e.toString()}');
    }
  }
}