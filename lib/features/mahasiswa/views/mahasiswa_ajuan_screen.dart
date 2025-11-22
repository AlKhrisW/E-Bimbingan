import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class MahasiswaAjuanScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaAjuanScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajukan Bimbingan"),
      ),
      body: Center(
        child: Text(
          "Halaman Ajuan Bimbingan\nNama: ${user.name ?? '-'}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
