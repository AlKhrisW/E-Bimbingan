import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';
import '../viewmodels/logbook_mingguan_viewmodel.dart';
import '../../../core/widgets/appbar/custom_appbar.dart';
import 'tambah_logbook_mingguan_screen.dart';
import 'detail_logbook_mingguan_screen.dart';

class MahasiswaLogbookScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaLogbookScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LogbookMingguanViewModel(mahasiswaUid: user.uid),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: const CustomAppbar(judul: "Logbook Mingguan"),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Menunggu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Expanded(
              child: Consumer<LogbookMingguanViewModel>(
                builder: (context, viewModel, child) {
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: viewModel.ajuanBimbinganStream,
                    builder: (context, ajuanSnapshot) {
                      if (ajuanSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (ajuanSnapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${ajuanSnapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!ajuanSnapshot.hasData || ajuanSnapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada bimbingan yang disetujui',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ajukan bimbingan terlebih dahulu\ndan tunggu persetujuan dosen',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: viewModel.logBimbinganStream,
                        builder: (context, logSnapshot) {
                          // Map logbook berdasarkan ajuanUid
                          final Map<String, Map<String, dynamic>> logbookMap = {};
                          
                          if (logSnapshot.hasData) {
                            for (var doc in logSnapshot.data!.docs) {
                              final data = doc.data();
                              final ajuanUid = data['ajuanUid'] as String?;
                              
                              if (ajuanUid != null) {
                                logbookMap[ajuanUid] = {
                                  'logBimbinganUid': doc.id,
                                  'status': data['status'] ?? 'draft',
                                  'ringkasanHasil': data['ringkasanHasil'] ?? '',
                                  'catatanDosen': data['catatanDosen'],
                                  'lampiranUrl': data['lampiranUrl'],
                                  'waktuPengajuan': data['waktuPengajuan'],
                                };
                              }
                            }
                          }

                          final allAjuan = ajuanSnapshot.data!.docs.map((doc) {
                            final data = doc.data();
                            final ajuanUid = doc.id;
                            
                            final logbook = logbookMap[ajuanUid];
                            final status = logbook?['status'] ?? 'draft';

                            return {
                              'ajuanUid': ajuanUid,
                              'mahasiswaUid': data['mahasiswaUid'],
                              'dosenUid': data['dosenUid'],
                              'namaMahasiswa': data['namaMahasiswa'] ?? '',
                              'namaDosen': data['namaDosen'] ?? '',
                              'topikBimbingan': data['topikBimbingan'] ??
                                  data['judulTopik'] ??
                                  'Konsultasi KLMN',
                              'tanggal': data['tanggal'] ?? data['tanggalBimbingan'],
                              'tanggalFormatted': data['tanggal'] != null
                                  ? LogbookMingguanViewModel.formatTanggal(data['tanggal'])
                                  : (data['tanggalBimbingan'] != null
                                      ? LogbookMingguanViewModel.formatTanggal(data['tanggalBimbingan'])
                                      : 'Tanggal tidak tersedia'),
                              'status': status,
                              'logBimbinganUid': logbook?['logBimbinganUid'],
                              'ringkasanHasil': logbook?['ringkasanHasil'] ?? '',
                            };
                          }).toList();

                          allAjuan.sort((a, b) {
                            final aDate = a['tanggal'] as Timestamp?;
                            final bDate = b['tanggal'] as Timestamp?;
                            if (aDate == null || bDate == null) return 0;
                            return bDate.toDate().compareTo(aDate.toDate());
                          });

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: allAjuan.length,
                            itemBuilder: (context, index) {
                              final ajuan = allAjuan[index];
                              return _buildLogbookCard(context, ajuan);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogbookCard(BuildContext context, Map<String, dynamic> ajuan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _handleCardTap(context, ajuan);
        },
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Judul',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ajuan['topikBimbingan'] ?? 'Konsultasi KLMN',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                buildStatusBadge(ajuan['status'] ?? 'draft'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Tanggal Bimbingan: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  ajuan['tanggalFormatted'] ?? 'Tanggal tidak tersedia',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleCardTap(BuildContext context, Map<String, dynamic> ajuan) {
    final status = (ajuan['status'] ?? 'draft').toString().toLowerCase();

    // Draft atau Rejected -> Buka form edit (TambahLogbookMingguanScreen)
    if (status == 'draft' || status == 'rejected') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TambahLogbookMingguanScreen(
            ajuanData: ajuan,
          ),
        ),
      );
    } 
    // Pending atau Approved -> Buka detail (read-only)
    else if (status == 'pending' || status == 'approved') {
      final logBimbinganUid = ajuan['logBimbinganUid'];
      
      if (logBimbinganUid == null || logBimbinganUid.isEmpty) {
        // Jika tidak ada logBimbinganUid, tampilkan error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data logbook tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailLogbookMingguanScreen(
            logBimbinganUid: logBimbinganUid,
          ),
        ),
      );
    }
  }

  Widget buildStatusBadge(String status) {
    Color bgColor;
    Color dotColor;
    String label;

    final statusLower = status.toLowerCase();

    switch (statusLower) {
      case "draft":
        bgColor = const Color(0xFFFFF4E5);
        dotColor = const Color(0xFFF59E0B);
        label = "Belum dibuat";
        break;

      case "pending":
        bgColor = const Color(0xFFE0F2FE);
        dotColor = const Color(0xFF0284C7);
        label = "Proses";
        break;

      case "approved":
        bgColor = const Color(0xFFE6FEE7);
        dotColor = const Color(0xFF16A34A);
        label = "Diterima";
        break;

      case "rejected":
        bgColor = const Color(0xFFFEE2E2);
        dotColor = const Color(0xFFDC2626);
        label = "Ditolak";
        break;

      default:
        bgColor = Colors.grey.shade200;
        dotColor = Colors.grey;
        label = "Unknown";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: dotColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: dotColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}