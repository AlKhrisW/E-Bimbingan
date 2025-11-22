import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class MahasiswaBimbinganScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaBimbinganScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bimbingan"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Halaman Bimbingan Mahasiswa",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
