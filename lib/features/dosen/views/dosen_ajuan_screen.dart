import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/custom_universal_back_appBar.dart';

class DosenAjuan extends StatelessWidget {
  final UserModel user;
  const DosenAjuan({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomUniversalAppbar(judul: "Ajuan Bimbingan"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Halaman Ajuan Bimbingan Mahasiswa"),
          ],
        ),
      ),
    );
  }
}