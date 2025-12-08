import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String judul;
  final PreferredSizeWidget? bottom;

  const CustomAppbar({
    super.key, 
    required this.judul, 
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        judul,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,
        ),
      ),
      bottom: bottom,
    );
  }

  @override
  // Menghitung tinggi total: Tinggi AppBar standar + Tinggi TabBar (jika ada)
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}