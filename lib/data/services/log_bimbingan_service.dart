import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/log_bimbingan_model.dart';

class LogBimbinganService {
  final CollectionReference _logBimbinganCollection = 
      FirebaseFirestore.instance.collection('log_bimbingan');

  // =================================================================
  // CREATE & UPDATE
  // =================================================================

  Future<void> saveLogBimbingan(LogBimbinganModel log) async {
    try {
      await _logBimbinganCollection.doc(log.logBimbinganUid).set(log.toMap());
    } catch (e) {
      throw Exception('gagal menyimpan log bimbingan: ${e.toString()}');
    }
  }

  Future<void> updateLogBimbinganStatus({
    required String logBimbinganUid,
    required LogBimbinganStatus status,
    String? catatanDosen,
  }) async {
    try {
      await _logBimbinganCollection.doc(logBimbinganUid).update({
        'status': status.toString().split('.').last,
        'catatanDosen': catatanDosen,
      });
    } catch (e) {
      throw Exception('gagal memperbarui status log bimbingan: ${e.toString()}');
    }
  }
  
  // =================================================================
  // READ (FUTURE / GET)
  // =================================================================

  Future<List<LogBimbinganModel>> getLogBimbinganByMahasiswaUid(String mahasiswaUid) async {
    try {
      final snapshot = await _logBimbinganCollection
          .where('mahasiswaUid', isEqualTo: mahasiswaUid)
          .orderBy('waktuPengajuan', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return LogBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('gagal mengambil log mahasiswa: ${e.toString()}');
    }
  }

  Future<List<LogBimbinganModel>> getPendingLogsByDosenUid(String dosenUid) async {
    try {
      final snapshot = await _logBimbinganCollection
          .where('dosenUid', isEqualTo: dosenUid)
          .where('status', isEqualTo: 'pending')
          .orderBy('waktuPengajuan', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return LogBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('gagal mengambil log pending dosen: ${e.toString()}');
    }
  }

  Future<List<LogBimbinganModel>> getRiwayatSpesifik(String dosenUid, String mahasiswaUid) async {
    try {
      final snapshot = await _logBimbinganCollection
          .where('dosenUid', isEqualTo: dosenUid)
          .where('mahasiswaUid', isEqualTo: mahasiswaUid)
          .orderBy('waktuPengajuan', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return LogBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('gagal mengambil riwayat spesifik: ${e.toString()}');
    }
  }

  // =================================================================
  // DELETE
  // =================================================================

  Future<void> deleteLogBimbingan(String logBimbinganUid) async {
    try {
      await _logBimbinganCollection.doc(logBimbinganUid).delete();
    } catch (e) {
      throw Exception('gagal menghapus log bimbingan: ${e.toString()}');
    }
  }
}