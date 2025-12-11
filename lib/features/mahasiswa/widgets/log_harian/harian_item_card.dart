import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_harian.dart';

class MahasiswaLogHarianItem extends StatelessWidget {
  final MahasiswaHarianHelper data;
  final VoidCallback onTap;

  const MahasiswaLogHarianItem({
    super.key,
    required this.data,
    required this.onTap,
  });

  // Helper getters
  LogbookStatus get status => data.logbook.status;

  Color get statusColor {
    switch (status) {
      case LogbookStatus.verified: return Colors.green;
      case LogbookStatus.draft: return Colors.orange; // Draft dianggap Pending
    }
  }

  String get statusText {
    switch (status) {
      case LogbookStatus.verified: return "Tervalidasi";
      case LogbookStatus.draft: return "Pending";
    }
  }

  IconData get statusIcon {
    switch (status) {
      case LogbookStatus.verified: return Icons.check_circle;
      case LogbookStatus.draft: return Icons.hourglass_top;
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
                        data.logbook.judulTopik, // Judul Topik
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // Format Tanggal: Senin, 12 Agustus 2024
                        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(data.logbook.tanggal),
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