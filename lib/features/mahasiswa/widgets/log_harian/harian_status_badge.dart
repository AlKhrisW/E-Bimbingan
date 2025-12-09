import 'package:flutter/material.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';

class MahasiswaHarianStatus extends StatelessWidget {
  final LogbookStatus status;

  const MahasiswaHarianStatus({
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
      case LogbookStatus.verified:
        // HIJAU
        bgColor = const Color(0xFFE6FEE7); 
        textColor = const Color(0xFF16A34A);
        text = "Disetujui";
        icon = Icons.check_circle;
        break;

      case LogbookStatus.draft:
        // ORANGE
        bgColor = const Color(0xFFFFF7ED); // Orange muda banget
        textColor = const Color(0xFFC2410C); // Orange tua
        text = "Menunggu Validasi";
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