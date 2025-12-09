import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';

class CustomAddFab extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const CustomAddFab({
    super.key,
    required this.onPressed,
    this.tooltip = "Tambah Data",
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null, // Set null jika ada banyak FAB, atau string unik
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppTheme.primaryColor, // Menggunakan warna tema
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}