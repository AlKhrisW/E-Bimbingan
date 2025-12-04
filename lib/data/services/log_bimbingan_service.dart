import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/log_bimbingan_model.dart';

class LogBimbinganService {
  final CollectionReference _logBimbinganCollection = 
      FirebaseFirestore.instance.collection('log_bimbingan');

  // ----------------------------------------------------------------------
  // create & update (c/u)
  // ----------------------------------------------------------------------

  /// menyimpan log bimbingan baru atau memperbarui yang sudah ada
  Future<void> saveLogBimbingan(LogBimbinganModel log) async {
    try {
      await _logBimbinganCollection.doc(log.logBimbinganUid).set(log.toMap());
    } catch (e) {
      throw Exception('gagal menyimpan log bimbingan: ${e.toString()}');
    }
  }

  /// memperbarui status log bimbingan oleh dosen
  Future<void> updateLogBimbinganStatus({
    required String logBimbinganUid,
    required LogBimbinganStatus status,
    String? catatanDosen,
  }) async {
    try {
      await _logBimbinganCollection.doc(logBimbinganUid).update({
        'status': status.toString().split('.').last, // simpan sebagai string lowercase
        'catatanDosen': catatanDosen,
      });
    } catch (e) {
      throw Exception('gagal memperbarui status log bimbingan: ${e.toString()}');
    }
  }
  
  // ----------------------------------------------------------------------
  // read (r)
  // ----------------------------------------------------------------------

  /// mengambil semua log bimbingan (mingguan) milik mahasiswa tertentu
  Stream<List<LogBimbinganModel>> getLogBimbinganByMahasiswaUid(String mahasiswaUid) {
    return _logBimbinganCollection
        .where('mahasiswaUid', isEqualTo: mahasiswaUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LogBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    });
  }

  /// mengambil log bimbingan yang menunggu persetujuan dosen
  Stream<List<LogBimbinganModel>> getPendingLogsByDosenUid(String dosenUid) {
    return _logBimbinganCollection
        .where('dosenUid', isEqualTo: dosenUid)
        .where('status', isEqualTo: LogBimbinganStatus.pending.toString().split('.').last)
        .orderBy('waktuPengajuan', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LogBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    });
  }

  // ----------------------------------------------------------------------
  // delete (d)
  // ----------------------------------------------------------------------

  /// menghapus log bimbingan
  Future<void> deleteLogBimbingan(String logBimbinganUid) async {
    try {
      await _logBimbinganCollection.doc(logBimbinganUid).delete();
    } catch (e) {
      throw Exception('gagal menghapus log bimbingan: ${e.toString()}');
    }
  }
}