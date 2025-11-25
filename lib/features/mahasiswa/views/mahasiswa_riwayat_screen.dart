import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class MahasiswaRiwayatScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaRiwayatScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // JUDUL DI TENGAH
            Center(
              child: Text(
                "Riwayat Bimbingan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Konten
            const Text(
              "Halaman Riwayat Bimbingan Mahasiswa",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
