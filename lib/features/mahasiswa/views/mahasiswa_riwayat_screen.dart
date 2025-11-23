import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class MahasiswaRiwayatScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaRiwayatScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Bimbingan"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Halaman Riwayat Bimbingan",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
