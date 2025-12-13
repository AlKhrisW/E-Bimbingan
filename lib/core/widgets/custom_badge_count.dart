import 'package:flutter/material.dart';

class CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  final Color textColor;

  const CountBadge({
    super.key,
    required this.count,
    this.color = Colors.red, // Default merah
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Jika 0, jangan tampilkan apa-apa (invisible)
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(4), 
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        // Tambahkan border putih agar badge 'terpisah' visualnya dari icon di belakangnya
        border: Border.all(color: Colors.white, width: 1.5), 
      ),
      constraints: const BoxConstraints(
        minWidth: 18, // Ukuran minimum agar bulat sempurna
        minHeight: 18,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count', // Logic pemendekan angka
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.0, 
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}