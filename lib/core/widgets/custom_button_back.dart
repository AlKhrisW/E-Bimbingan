// lib/core/widgets/custom_button_back.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_theme.dart';

class CustomBackButton extends StatelessWidget {
  final Color? color;
  final double size;

  const CustomBackButton({
    super.key,
    this.color,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // Padding agar tombol terlihat lebih rapi
      padding: EdgeInsets.zero, 
      icon: Container(
        // FIX: Bungkus Icon dalam Container/Circle
        width: size + 10, // Tambahkan sedikit padding di sekitar icon
        height: size + 10,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor, // Background Biru Tema
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            // FIX: Menggunakan Icon Arrow standar untuk iOS/Material
            Icons.arrow_back_ios_new, 
            // FIX: Set warna icon menjadi PUTIH
            color: Colors.white, 
            // FIX: Ukuran icon sedikit lebih kecil agar muat di dalam lingkaran
            size: size * 0.7, 
          ),
        ),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
    );
  }
}