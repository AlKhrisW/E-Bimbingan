import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../data/models/log_bimbingan_model.dart';
import '../../../data/services/log_bimbingan_service.dart';

class LogbookMingguanViewModel extends ChangeNotifier {
  final String mahasiswaUid;
  final LogBimbinganService _logService = LogBimbinganService();

  LogbookMingguanViewModel({required this.mahasiswaUid});

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ===================== STREAM =====================
  
  Stream<QuerySnapshot<Map<String, dynamic>>> get ajuanBimbinganStream {
    return FirebaseFirestore.instance
        .collection('ajuan_bimbingan')
        .where('mahasiswaUid', isEqualTo: mahasiswaUid)
        .where('status', isEqualTo: 'disetujui')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get logBimbinganStream {
    return FirebaseFirestore.instance
        .collection('log_bimbingan')
        .where('mahasiswaUid', isEqualTo: mahasiswaUid)
        .snapshots();
  }

  // ===================== LOGIC UTAMA (SUBMIT DENGAN BASE64) =====================
  
  Future<bool> submitLogBimbingan({
    required String ajuanUid,
    required String mahasiswaUid,
    required String dosenUid,
    required String ringkasanHasil,
    File? lampiranFile,
    Uint8List? lampiranBytes,
    String? fileName,
    String? existingLogBimbinganUid, 
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validasi Input
      if (ajuanUid.isEmpty || ringkasanHasil.trim().isEmpty) {
        throw Exception('Ringkasan hasil wajib diisi');
      }

      if (mahasiswaUid.isEmpty) {
        throw Exception('mahasiswaUid tidak valid');
      }

      // Cari logbook yang sudah ada untuk ajuanUid ini
      final existingQuery = await FirebaseFirestore.instance
          .collection('log_bimbingan')
          .where('ajuanUid', isEqualTo: ajuanUid)
          .where('mahasiswaUid', isEqualTo: mahasiswaUid)
          .limit(1)
          .get();

      String logBimbinganUid;
      String? finalLampiranBase64;
      String? finalFileName;
      DateTime? existingWaktuPengajuan;
      LogBimbinganStatus finalStatus = LogBimbinganStatus.pending;
      bool isEditMode = false;

      if (existingQuery.docs.isNotEmpty) {
        // SUDAH ADA - UPDATE
        isEditMode = true;
        final existingDoc = existingQuery.docs.first;
        logBimbinganUid = existingDoc.id;
        
        final data = existingDoc.data();
        finalLampiranBase64 = data['lampiranUrl'];
        finalFileName = data['fileName'];
        existingWaktuPengajuan = (data['waktuPengajuan'] as Timestamp?)?.toDate();
        
        final statusString = data['status'] as String?;
        if (statusString != null) {
          try {
            finalStatus = LogBimbinganStatus.values.firstWhere(
              (e) => e.toString().split('.').last == statusString,
              orElse: () => LogBimbinganStatus.pending,
            );
          } catch (e) {
            finalStatus = LogBimbinganStatus.pending;
          }
        }
      } else {
        // BELUM ADA - CREATE BARU
        isEditMode = false;
        logBimbinganUid = FirebaseFirestore.instance
            .collection('log_bimbingan')
            .doc()
            .id;
      }

      // Encode gambar ke Base64 (jika ada file baru)
      final bool hasNewFile = lampiranFile != null || lampiranBytes != null;
      
      if (hasNewFile) {
        try {
          final base64String = await _logService.encodeImageToBase64(
            file: lampiranFile,
            bytes: lampiranBytes,
          );

          if (base64String != null && base64String.isNotEmpty) {
            finalLampiranBase64 = base64String;
            finalFileName = fileName; // Simpan nama file baru
          } else {
            throw Exception('Encode gagal: Base64 string kosong');
          }
        } catch (e) {
          _isLoading = false;
          _errorMessage = 'Gagal encode gambar: $e';
          notifyListeners();
          return false;
        }
      }

      // Validasi: Pastikan ada Base64 (wajib untuk create baru)
      if (!isEditMode && (finalLampiranBase64 == null || finalLampiranBase64.isEmpty)) {
        _isLoading = false;
        _errorMessage = 'Lampiran bukti kehadiran wajib diupload';
        notifyListeners();
        return false;
      }

      // Simpan data ke Firestore
      final logBimbingan = LogBimbinganModel(
        logBimbinganUid: logBimbinganUid,
        ajuanUid: ajuanUid,
        mahasiswaUid: mahasiswaUid,
        dosenUid: dosenUid,
        ringkasanHasil: ringkasanHasil.trim(),
        lampiranUrl: finalLampiranBase64,
        fileName: finalFileName,
        status: finalStatus,
        waktuPengajuan: existingWaktuPengajuan ?? DateTime.now(),
      );
      
      await _logService.saveLogBimbingan(logBimbingan);

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Gagal memproses data: $e';
      notifyListeners();
      return false;
    }
  }

  // ===================== CRUD LAINNYA =====================

  Future<bool> updateStatusLogBimbingan({
    required String logBimbinganUid,
    required LogBimbinganStatus newStatus,
    String? catatanDosen,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _logService.updateLogBimbinganStatus(
        logBimbinganUid: logBimbinganUid,
        status: newStatus,
        catatanDosen: catatanDosen,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLogBimbingan(String logBimbinganUid) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _logService.deleteLogBimbingan(logBimbinganUid);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===================== HELPER & MAPPING =====================
  
  Future<List<Map<String, dynamic>>> getAvailableAjuan(
      QuerySnapshot<Map<String, dynamic>> ajuanSnapshot) async {
    final logSnapshot = await FirebaseFirestore.instance
        .collection('log_bimbingan')
        .where('mahasiswaUid', isEqualTo: mahasiswaUid)
        .get();

    final existingLogs =
        logSnapshot.docs.map((doc) => doc.data()['ajuanUid'] as String).toSet();

    final results = ajuanSnapshot.docs
        .where((doc) => !existingLogs.contains(doc.id))
        .map((doc) {
      final data = doc.data();
      return {
        'ajuanUid': doc.id,
        'mahasiswaUid': data['mahasiswaUid'],
        'dosenUid': data['dosenUid'],
        'namaMahasiswa': data['namaMahasiswa'] ?? '',
        'namaDosen': data['namaDosen'] ?? '',
        'topikBimbingan': data['topikBimbingan'] ?? 'Konsultasi KLMN',
        'tanggal': data['tanggal'],
        'tanggalFormatted': formatTanggalDynamic(data['tanggal']),
      };
    }).toList();

    results.sort((a, b) {
      final aDate = (a['tanggal'] as Timestamp?)?.toDate();
      final bDate = (b['tanggal'] as Timestamp?)?.toDate();
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    return results;
  }

  static String formatTanggalDynamic(dynamic tanggal) {
    if (tanggal == null) return 'Tanggal tidak tersedia';
    if (tanggal is Timestamp) return formatTanggal(tanggal);
    return 'Tanggal tidak valid';
  }

  static String formatTanggal(Timestamp ts) {
    final date = ts.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisDate = DateTime(date.year, date.month, date.day);

    if (thisDate == today) return 'Today';
    if (thisDate == today.subtract(const Duration(days: 1))) return 'Yesterday';

    return '${date.day} ${_namaBulan(date.month)} ${date.year}';
  }

  static String _namaBulan(int m) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulan[m];
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}