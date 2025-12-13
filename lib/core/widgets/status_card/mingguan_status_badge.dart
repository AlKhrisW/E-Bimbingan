import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';

class MingguanStatus extends StatelessWidget {
  final LogBimbinganStatus status;

  const MingguanStatus({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case LogBimbinganStatus.approved:
        // HIJAU
        bgColor = const Color(0xFFE6FEE7); 
        textColor = const Color(0xFF16A34A);
        text = "Disetujui";
        icon = Icons.check_circle;
        break;

      case LogBimbinganStatus.rejected:
        // MERAH
        bgColor = const Color(0xFFFEE2E2); 
        textColor = const Color(0xFFDC2626);
        text = "Perlu Revisi";
        icon = Icons.cancel;
        break;

      case LogBimbinganStatus.pending:
        // ORANGE
        bgColor = const Color(0xFFFFF7ED); // Orange muda banget
        textColor = const Color(0xFFC2410C); // Orange tua
        text = "Menunggu Persetujuan";
        icon = Icons.hourglass_top;
        break;

      default: // Draft
        // ABU-ABU
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        text = "Draft";
        icon = Icons.edit_note;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}