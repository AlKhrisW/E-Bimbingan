import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class MahasiswaLaporanScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaLaporanScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan Harian"),
      ),
      body: Center(
        child: Text(
          "Halaman Laporan Harian\nNama: ${user.name ?? '-'}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
