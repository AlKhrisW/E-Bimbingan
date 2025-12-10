import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/logbook_harian_model.dart';

class LogbookHarianService {
  final CollectionReference _logbookHarianCollection = 
      FirebaseFirestore.instance.collection('logbook_harian');

  // ----------------------------------------------------------------------
  // create & update (c/u)
  // ----------------------------------------------------------------------

  /// menyimpan logbook harian baru atau memperbarui yang sudah ada
  Future<void> saveLogbookHarian(LogbookHarianModel logbook) async {
    try {
      await _logbookHarianCollection.doc(logbook.logbookHarianUid).set(logbook.toMap());
    } catch (e) {
      throw Exception('gagal menyimpan logbook harian: ${e.toString()}');
    }
  }

  /// memperbarui status banyak logbook sekaligus (digunakan untuk auto-verification)
  Future<void> batchUpdateStatus({
    required List<String> logbookUids,
    required LogbookStatus newStatus,
  }) async {
    if (logbookUids.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final statusString = newStatus.toString().split('.').last;

    for (var uid in logbookUids) {
      final docRef = _logbookHarianCollection.doc(uid);
      batch.update(docRef, {'status': statusString});
    }

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('gagal melakukan batch update status logbook harian: ${e.toString()}');
    }
  }

  // ----------------------------------------------------------------------
  // read (r) - SEKARANG MENGGUNAKAN FUTURE
  // ----------------------------------------------------------------------

  /// mengambil semua logbook harian milik mahasiswa tertentu
  Future<List<LogbookHarianModel>> getLogbookByMahasiswaUid(String mahasiswaUid) async {
    try {
      final snapshot = await _logbookHarianCollection
          .where('mahasiswaUid', isEqualTo: mahasiswaUid)
          .orderBy('tanggal', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return LogbookHarianModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('gagal mengambil logbook mahasiswa: ${e.toString()}');
    }
  }
  
  /// mengambil logbook spesifik berdasarkan mahasiswa dan dosen
  Future<List<LogbookHarianModel>> getLogbook(String mahasiswaUid, String dosenUid) async {
    try {
      final snapshot = await _logbookHarianCollection
          .where('dosenUid', isEqualTo: dosenUid)
          .where('mahasiswaUid', isEqualTo: mahasiswaUid)
          .orderBy('tanggal', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return LogbookHarianModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('gagal mengambil logbook spesifik: ${e.toString()}');
    }
  }

  Future<LogbookHarianModel?> getLogbookById(String logbookId) async {
    try {
      final doc = await _logbookHarianCollection.doc(logbookId).get();
      
      if (doc.exists) {
        return LogbookHarianModel.fromMap(doc.data()! as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// mengambil logbook harian dalam rentang tanggal tertentu
  Future<List<LogbookHarianModel>> getLogbooksInDateRange({
    required String mahasiswaUid,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // normalize datetime to start/end of day for accurate firestore query
      final startTimestamp = Timestamp.fromDate(DateTime(startDate.year, startDate.month, startDate.day));
      final endTimestamp = Timestamp.fromDate(DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59));
      
      final snapshot = await _logbookHarianCollection
          .where('mahasiswaUid', isEqualTo: mahasiswaUid)
          .where('tanggal', isGreaterThanOrEqualTo: startTimestamp)
          .where('tanggal', isLessThanOrEqualTo: endTimestamp)
          .get();

      return snapshot.docs.map((doc) {
        return LogbookHarianModel.fromMap(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('gagal mengambil logbook dalam rentang tanggal: ${e.toString()}');
    }
  }

  // ----------------------------------------------------------------------
  // delete (d)
  // ----------------------------------------------------------------------

  /// menghapus logbook harian
  Future<void> deleteLogbookHarian(String logbookUid) async {
    try {
      await _logbookHarianCollection.doc(logbookUid).delete();
    } catch (e) {
      throw Exception('gagal menghapus logbook harian: ${e.toString()}');
    }
  }
}