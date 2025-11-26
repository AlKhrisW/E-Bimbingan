import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/custom_universal_back_appBar.dart';

class MahasiswaLaporanScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaLaporanScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomUniversalAppbar(judul: "Laporan Harian"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Halaman Laporan Harian Mahasiswa",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            Text(
              "Nama: ${user.name ?? '-'}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
