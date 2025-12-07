import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/helper_log_bimbingan.dart';
import 'package:ebimbingan/features/dosen/views/log_bimbingan/riwayat/riwayat_detail_screen.dart';

class RiwayatItem extends StatelessWidget {
  final HelperLogBimbingan data;

  const RiwayatItem({super.key, required this.data});

  // Helper untuk Status Warna & Text
  bool get isDisetujui => data.log.status == LogBimbinganStatus.approved;
  bool get isDitolak => data.log.status == LogBimbinganStatus.rejected;

  Color get statusColor {
    if (isDisetujui) return Colors.green;
    if (isDitolak) return Colors.red;
    return Colors.orange;
  }

  String get statusText {
    if (isDisetujui) return "Disetujui";
    if (isDitolak) return "Ditolak";
    return "Proses";
  }

  IconData get statusIcon {
    if (isDisetujui) return Icons.check_circle;
    if (isDitolak) return Icons.cancel;
    return Icons.access_time_filled;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        elevation: 2,
        color: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DosenRiwayatBimbinganDetail(data: data),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Status
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),

                // Konten Teks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.ajuan.judulTopik,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(data.log.waktuPengajuan),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Badge Status Kecil
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}