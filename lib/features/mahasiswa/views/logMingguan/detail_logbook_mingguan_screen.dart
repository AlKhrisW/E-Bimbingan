import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import '../../../../data/services/log_bimbingan_service.dart';
import '../../../../data/models/log_bimbingan_model.dart';

class DetailLogbookMingguanScreen extends StatefulWidget {
  final String logBimbinganUid;

  const DetailLogbookMingguanScreen({
    super.key,
    required this.logBimbinganUid,
  });

  @override
  State<DetailLogbookMingguanScreen> createState() =>
      _DetailLogbookMingguanScreenState();
}

class _DetailLogbookMingguanScreenState
    extends State<DetailLogbookMingguanScreen> {
  final LogBimbinganService _logService = LogBimbinganService();

  bool _isLoading = true;
  String _errorMessage = '';

  // Data logbook
  String _namaMahasiswa = '';
  String _namaDosen = '';
  String _tanggalBimbingan = '';
  String _topikBimbingan = '';
  String _ringkasanHasil = '';
  String? _fileName;
  String? _base64Image;
  String _status = '';
  String? _catatanDosen;

  @override
  void initState() {
    super.initState();
    _loadLogbookData();
  }

  Future<void> _loadLogbookData() async {
    try {
      final logDoc = await FirebaseFirestore.instance
          .collection('log_bimbingan')
          .doc(widget.logBimbinganUid)
          .get();

      if (!logDoc.exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Data logbook tidak ditemukan';
        });
        return;
      }

      final logData = logDoc.data()!;

      final ajuanUid = logData['ajuanUid'];
      final ajuanDoc = await FirebaseFirestore.instance
          .collection('ajuan_bimbingan')
          .doc(ajuanUid)
          .get();

      String topik = 'Konsultasi KLMN';
      String tanggal = 'Tanggal tidak tersedia';

      if (ajuanDoc.exists) {
        final ajuanData = ajuanDoc.data()!;
        topik = ajuanData['topikBimbingan'] ?? 'Konsultasi KLMN';
        
        final tanggalTimestamp = ajuanData['tanggal'];
        if (tanggalTimestamp != null) {
          tanggal = _formatTanggal(tanggalTimestamp);
        }
      }

      final mahasiswaUid = logData['mahasiswaUid'];
      final mahasiswaDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(mahasiswaUid)
          .get();

      String namaMahasiswa = 'Mahasiswa tidak ditemukan';
      if (mahasiswaDoc.exists) {
        final mahasiswaData = mahasiswaDoc.data()!;
        namaMahasiswa = mahasiswaData['name'] ?? mahasiswaData['nama'] ?? namaMahasiswa;
      }

      final dosenUid = logData['dosenUid'];
      final dosenDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(dosenUid)
          .get();

      String namaDosen = 'Dosen tidak ditemukan';
      if (dosenDoc.exists) {
        final dosenData = dosenDoc.data()!;
        namaDosen = dosenData['name'] ?? dosenData['nama'] ?? namaDosen;
      }

      if (mounted) {
        setState(() {
          _namaMahasiswa = namaMahasiswa;
          _namaDosen = namaDosen;
          _tanggalBimbingan = tanggal;
          _topikBimbingan = topik;
          _ringkasanHasil = logData['ringkasanHasil'] ?? '';
          _fileName = logData['fileName'];
          _base64Image = logData['lampiranUrl'];
          _status = _getStatusText(logData['status']);
          _catatanDosen = logData['catatanDosen'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error memuat data: $e';
        });
      }
    }
  }

  String _formatTanggal(dynamic tanggal) {
    try {
      final DateTime date = tanggal is Timestamp
          ? tanggal.toDate()
          : DateTime.parse(tanggal.toString());

      return '${date.day.toString().padLeft(2, '0')} - ${date.month.toString().padLeft(2, '0')} - ${date.year}';
    } catch (_) {
      return 'Tanggal tidak tersedia';
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'draft':
        return 'Draft';
      default:
        return 'Tidak Diketahui';
    }
  }

  Color _getStatusColor(String status) {
    if (status.contains('Menunggu')) {
      return const Color(0xFF0284C7);
    } else if (status.contains('Disetujui')) {
      return const Color(0xFF16A34A);
    } else if (status.contains('Ditolak')) {
      return const Color(0xFFDC2626);
    } else if (status.contains('Draft')) {
      return const Color(0xFFF59E0B);
    } else {
      return Colors.grey;
    }
  }

  Color _getStatusBadgeColor(String status) {
    if (status.contains('Menunggu')) {
      return const Color(0xFFE0F2FE);
    } else if (status.contains('Disetujui')) {
      return const Color(0xFFE6FEE7);
    } else if (status.contains('Ditolak')) {
      return const Color(0xFFFEE2E2);
    } else if (status.contains('Draft')) {
      return const Color(0xFFFFF4E5);
    } else {
      return Colors.grey.shade200;
    }
  }

  IconData _getStatusIcon(String status) {
    if (status.contains('Menunggu')) {
      return Icons.pending;
    } else if (status.contains('Disetujui')) {
      return Icons.check_circle;
    } else if (status.contains('Ditolak')) {
      return Icons.cancel;
    } else if (status.contains('Draft')) {
      return Icons.edit;
    } else {
      return Icons.help_outline;
    }
  }

  String _getStatusLabel(String status) {
    if (status.contains('Menunggu')) {
      return 'Proses';
    } else if (status.contains('Disetujui')) {
      return 'Diterima';
    } else if (status.contains('Ditolak')) {
      return 'Ditolak';
    } else if (status.contains('Draft')) {
      return 'Belum dibuat';
    } else {
      return 'Unknown';
    }
  }

  Widget _buildImagePreview() {
    if (_base64Image != null && _base64Image!.isNotEmpty) {
      final imageBytes = _logService.decodeBase64ToImage(_base64Image!);
      if (imageBytes != null) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GestureDetector(
              onTap: () => _showFullImage(imageBytes),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Tidak ada gambar',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showFullImage(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(imageBytes),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomUniversalAppbar(
          judul: 'Detail Logbook',
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: CustomUniversalAppbar(
          judul: 'Detail Logbook',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomUniversalAppbar(
        judul: _topikBimbingan,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mahasiswa
                  const Text(
                    'Mahasiswa',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildReadOnlyField(_namaMahasiswa),
                  const SizedBox(height: 16),

                  // Dosen Pembimbing
                  const Text(
                    'Dosen Pembimbing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildReadOnlyField(_namaDosen),
                  const SizedBox(height: 16),

                  // Tanggal
                  const Text(
                    'Tanggal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildReadOnlyField(_tanggalBimbingan),
                  const SizedBox(height: 16),

                  // Ringkasan Hasil
                  const Text(
                    'Ringkasan Hasil',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      _ringkasanHasil.isEmpty ? 'Tidak ada ringkasan' : _ringkasanHasil,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bukti Kehadiran
                  const Text(
                    'Bukti Kehadiran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _fileName ?? 'Tidak ada file',
                            style: TextStyle(
                              color: _fileName != null ? Colors.black87 : Colors.grey[600],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Image Preview
                  _buildImagePreview(),
                  const SizedBox(height: 16),

                  // Catatan Dosen (selalu tampil)
                  const Text(
                    'Catatan Dosen',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_catatanDosen != null && _catatanDosen!.isNotEmpty) 
                          ? Colors.blue[50] 
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (_catatanDosen != null && _catatanDosen!.isNotEmpty)
                            ? Colors.blue[200]!
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: (_catatanDosen != null && _catatanDosen!.isNotEmpty)
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _catatanDosen!,
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '-',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                  ),

                  const SizedBox(height: 80), // Space for fixed status button
                ],
              ),
            ),
          ),

          // Fixed Status Button at Bottom
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _getStatusBadgeColor(_status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(_status),
                    color: _getStatusColor(_status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusLabel(_status),
                    style: TextStyle(
                      color: _getStatusColor(_status),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
      ),
    );
  }
}