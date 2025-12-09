import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/log_bimbingan_model.dart';

class LogBimbinganService {
  final CollectionReference _logBimbinganCollection = 
      FirebaseFirestore.instance.collection('log_bimbingan');
  
  // ======================================================================
  // HELPERS (Encode/Decode)
  // ======================================================================
  
  Future<String?> encodeImageToBase64(File file) async {
    try {
      final imageBytes = await file.readAsBytes();
      final base64String = base64Encode(imageBytes);
      
      if (base64String.length > 900000) {
        throw Exception('Ukuran gambar terlalu besar (Maksimal ~700KB).');
      }
      return base64String;
    } catch (e) {
      throw Exception('Gagal memproses gambar: $e');
    }
  }

  Uint8List? decodeBase64ToImage(String? base64String) {
    try {
      if (base64String == null || base64String.isEmpty) return null;
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  // ======================================================================
  // SIMPAN LOG BIMBINGAN
  // ======================================================================
  
  Future<void> saveLogBimbingan(LogBimbinganModel log) async {
    try {
      final data = log.toMap();
      
      await _logBimbinganCollection.doc(log.logBimbinganUid).set(
        data, 
        SetOptions(merge: true)
      );
      
    } catch (e) {
      if (e.toString().contains('too large')) {
        throw Exception('Data terlalu besar untuk Firestore. Kurangi ukuran gambar.');
      }
      
      throw Exception('Gagal menyimpan log bimbingan: $e');
    }
  }


  // ======================================================================
  // UPDATE 1: KHUSUS MAHASISWA (Pengajuan/Revisi)
  // ======================================================================
  
  Future<void> updateLogBimbinganMahasiswa({
    required String logBimbinganUid,
    required String ringkasanHasil,
    required LogBimbinganStatus status,
    required DateTime waktuPengajuan,
    File? fileFoto,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {
        'ringkasanHasil': ringkasanHasil,
        'status': status.toString().split('.').last,
        'waktuPengajuan': Timestamp.fromDate(waktuPengajuan),
      };

      if (fileFoto != null) {
        String? base64Image = await encodeImageToBase64(fileFoto);
        if (base64Image != null) {
          dataToUpdate['lampiranUrl'] = base64Image;
          dataToUpdate['fileName'] = fileFoto.path.split(Platform.pathSeparator).last;
        }
      }

      await _logBimbinganCollection.doc(logBimbinganUid).update(dataToUpdate);
      
    } catch (e) {
      throw Exception('Gagal update pengajuan: $e');
    }
  }

  // ======================================================================
  // UPDATE 2: KHUSUS DOSEN (Verifikasi)
  // ======================================================================

  Future<void> updateStatusVerifikasi({
    required String logBimbinganUid,
    required LogBimbinganStatus status,
    String? catatanDosen,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {
        'status': status.toString().split('.').last,
        'catatanDosen': catatanDosen,
      };

      await _logBimbinganCollection.doc(logBimbinganUid).update(dataToUpdate);
      
    } catch (e) {
      throw Exception('Gagal verifikasi bimbingan: $e');
    }
  }
  
  // =================================================================
  // READ DATA (GETTERS)
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
      throw Exception('Gagal mengambil data mahasiswa: $e');
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
      throw Exception('Gagal mengambil data pending dosen: $e');
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
      throw Exception('Gagal mengambil riwayat spesifik: $e');
    }
  }

  Future<LogBimbinganModel?> getLogBimbinganByUid(String logBimbinganUid) async {
    try {
      final doc = await _logBimbinganCollection.doc(logBimbinganUid).get();
      if (doc.exists) {
        return LogBimbinganModel.fromMap(doc.data()! as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Gagal mengambil detail log: $e');
    }
  }

  // =================================================================
  // DELETE
  // =================================================================

  Future<void> deleteLogBimbingan(String logBimbinganUid) async {
    try {
      await _logBimbinganCollection.doc(logBimbinganUid).delete();
    } catch (e) {
      throw Exception('Gagal hapus log: $e');
    }
  }
}