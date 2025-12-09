import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_ajuan.dart';

class MahasiswaAjuanItem extends StatelessWidget {
  final MahasiswaAjuanHelper data;
  final VoidCallback onTap;

  const MahasiswaAjuanItem({
    super.key,
    required this.data,
    required this.onTap,
  });

  // Helper getters
  AjuanStatus get status => data.ajuan.status;

  Color get statusColor {
    switch (status) {
      case AjuanStatus.disetujui: return Colors.green;
      case AjuanStatus.ditolak: return Colors.red;
      case AjuanStatus.proses: return Colors.orange;
    }
  }

  String get statusText {
    switch (status) {
      case AjuanStatus.disetujui: return "Disetujui";
      case AjuanStatus.ditolak: return "Revisi";
      case AjuanStatus.proses: return "Menunggu";
    }
  }

  IconData get statusIcon {
    switch (status) {
      case AjuanStatus.disetujui: return Icons.check_circle;
      case AjuanStatus.ditolak: return Icons.warning_amber_rounded;
      case AjuanStatus.proses: return Icons.access_time_filled;
    }
  }


  @override
  Widget build(BuildContext context) {
    final formatDate = DateFormat('dd MMM yyyy • HH:mm').format(data.ajuan.tanggalBimbingan);
    
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
                        formatDate,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
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