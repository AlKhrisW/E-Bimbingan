import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/custom_appbar.dart';

class MahasiswaLogbookScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaLogbookScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(judul: "Logbook Mingguan"), 
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Halaman Logbook Mingguan Mahasiswa",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              "Nama: ${user.name}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
