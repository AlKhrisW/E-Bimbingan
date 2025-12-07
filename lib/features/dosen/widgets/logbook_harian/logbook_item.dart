import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/features/dosen/views/log_harian/detail_screen.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';

class LogbookItem extends StatelessWidget {
  final LogbookHarianModel logbook;

  const LogbookItem({super.key, required this.logbook});

  bool get isVerified => logbook.status == LogbookStatus.verified;
  bool get isDraft => logbook.status == LogbookStatus.draft; 

  Color get statusColor {
    if (isVerified) {
      return Colors.green;
    } else {
      return Colors.orangeAccent;
    }
  }

  String get statusText {
    if (isVerified) {
      return "Tervalidasi";
    } else {
      return "Pending";
    }
  }

  IconData get statusIcon {
    if (isVerified) {
      return Icons.check_circle;
    } else {
      return Icons.schedule; 
    }
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LogbookHarianDetail(logbook: logbook),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Status dalam lingkaran transparan
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
                        logbook.judulTopik,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM yyyy', 'id_ID').format(logbook.tanggal),
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