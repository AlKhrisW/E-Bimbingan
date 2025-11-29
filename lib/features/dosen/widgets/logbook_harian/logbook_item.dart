import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';

class LogbookItem extends StatelessWidget {
  final LogbookHarianModel logbook;

  const LogbookItem({super.key, required this.logbook});

  bool get isVerified => logbook.status == LogbookStatus.verified;

  Color get statusColor =>
      isVerified ? Colors.green : Colors.orange.shade700;

  String get statusText => isVerified ? "Terverifikasi" : "Draft";

  IconData get statusIcon =>
      isVerified ? Icons.check_circle : Icons.schedule;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          logbook.judulTopik,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              DateFormat('dd MMMM yyyy', 'id_ID').format(logbook.tanggal),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              logbook.deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Chip(
          backgroundColor: statusColor.withOpacity(0.15),
          label: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(logbook.judulTopik)),
          );
        },
      ),
    );
  }
}
