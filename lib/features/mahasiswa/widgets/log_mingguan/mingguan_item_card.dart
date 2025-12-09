import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_mingguan.dart';

class MahasiswaLogItem extends StatelessWidget {
  final MahasiswaMingguanHelper data;
  final VoidCallback onTap;

  const MahasiswaLogItem({
    super.key,
    required this.data,
    required this.onTap,
  });

  // Helper getters
  LogBimbinganStatus get status => data.log.status;

  Color get statusColor {
    switch (status) {
      case LogBimbinganStatus.approved: return Colors.green;
      case LogBimbinganStatus.rejected: return Colors.red;
      case LogBimbinganStatus.pending: return Colors.orange;
      case LogBimbinganStatus.draft: return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case LogBimbinganStatus.approved: return "Disetujui";
      case LogBimbinganStatus.rejected: return "Revisi";
      case LogBimbinganStatus.pending: return "Menunggu";
      case LogBimbinganStatus.draft: return "Draft (Isi Segera)";
    }
  }

  IconData get statusIcon {
    switch (status) {
      case LogBimbinganStatus.approved: return Icons.check_circle;
      case LogBimbinganStatus.rejected: return Icons.warning_amber_rounded;
      case LogBimbinganStatus.pending: return Icons.access_time_filled;
      case LogBimbinganStatus.draft: return Icons.edit_document;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
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
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                
                const SizedBox(width: 16),

                // Content
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
                        status == LogBimbinganStatus.draft 
                            ? "Silakan lengkapi laporan ini"
                            : DateFormat('dd MMM yyyy • HH:mm').format(data.log.waktuPengajuan),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontStyle: status == LogBimbinganStatus.draft ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Badge Status
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