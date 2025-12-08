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
  // ENCODE GAMBAR KE BASE64
  // ======================================================================
  
  Future<String?> encodeImageToBase64({
    required File? file,
    required Uint8List? bytes,
  }) async {
    try {
      Uint8List imageBytes;
      
      if (kIsWeb && bytes != null) {
        imageBytes = bytes;
      } else if (file != null) {
        imageBytes = await file.readAsBytes();
      } else {
        return null;
      }
      
      final base64String = base64Encode(imageBytes);
      
      if (base64String.length > 900000) {
        throw Exception('Gambar terlalu besar. Maksimal ~800KB setelah di-encode.');
      }
      
      return base64String;
      
    } catch (e) {
      throw Exception('Gagal encode gambar: $e');
    }
  }

  // ======================================================================
  // DECODE BASE64 KE IMAGE
  // ======================================================================
  
  Uint8List? decodeBase64ToImage(String? base64String) {
    try {
      if (base64String == null || base64String.isEmpty) {
        return null;
      }
      
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
  // CRUD OPERATIONS
  // ======================================================================

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
      throw Exception('Gagal update status: $e');
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
      throw Exception('Gagal hapus log: $e');
    }
  }
}