import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/logbook_harian_model.dart';

class LogbookHarianService {
  final CollectionReference _logbookHarianCollection = 
      FirebaseFirestore.instance.collection('logbook_harian');

  // ----------------------------------------------------------------------
  // create
  // ----------------------------------------------------------------------

  /// menyimpan logbook harian baru atau memperbarui yang sudah ada
  Future<void> saveLogbookHarian(LogbookHarianModel logbook) async {
    try {
      await _logbookHarianCollection.doc(logbook.logbookHarianUid).set(logbook.toMap());
    } catch (e) {
      throw Exception('gagal menyimpan logbook harian: ${e.toString()}');
    }
  }

  // ----------------------------------------------------------------------
  // update - AUTO VERIFICATION
  // ----------------------------------------------------------------------

  /// Memvalidasi semua logbook harian DRAFT dalam rentang tanggal tertentu
  Future<int> autoVerifyLogbookInRange({
    required String mahasiswaUid,
    required String dosenUid,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 1. Normalisasi tanggal agar mencakup jam 00:00 sampai 23:59
      final startTimestamp = Timestamp.fromDate(
          DateTime(startDate.year, startDate.month, startDate.day));
      final endTimestamp = Timestamp.fromDate(
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59));

      // 2. Query Logbook yang masih DRAFT dalam range
      final snapshot = await _logbookHarianCollection
          .where('dosenUid', isEqualTo: dosenUid)
          .where('mahasiswaUid', isEqualTo: mahasiswaUid)
          .where('status', isEqualTo: 'draft') 
          .where('tanggal', isGreaterThanOrEqualTo: startTimestamp)
          .where('tanggal', isLessThanOrEqualTo: endTimestamp)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      // 3. Ambil List UID
      List<String> logbookUids = snapshot.docs.map((doc) => doc.id).toList();

      // 4. Batch Update
      await batchUpdateStatus(
        logbookUids: logbookUids, 
        newStatus: LogbookStatus.verified
      );

      return logbookUids.length;
    } catch (e) {
      throw Exception('Gagal auto-verify logbook harian: ${e.toString()}');
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