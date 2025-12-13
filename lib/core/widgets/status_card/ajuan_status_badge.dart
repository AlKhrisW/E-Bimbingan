import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';

class StatusAjuan extends StatelessWidget {
  final AjuanStatus status;

  const StatusAjuan({
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
      case AjuanStatus.disetujui:
        // HIJAU
        bgColor = const Color(0xFFE6FEE7); 
        textColor = const Color(0xFF16A34A);
        text = "Disetujui";
        icon = Icons.check_circle;
        break;

      case AjuanStatus.ditolak:
        // MERAH
        bgColor = const Color(0xFFFEE2E2); 
        textColor = const Color(0xFFDC2626);
        text = "Ditolak";
        icon = Icons.cancel;
        break;

      case AjuanStatus.proses:
        // ORANGE
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFC2410C);
        text = "Menunggu Persetujuan";
        icon = Icons.hourglass_top;
        break;
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