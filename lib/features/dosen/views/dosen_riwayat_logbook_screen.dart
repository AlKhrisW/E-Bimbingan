import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class DosenRiwayatLogbook extends StatelessWidget {
  final UserModel user;
  const DosenRiwayatLogbook({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Logbook")),
      body: Center(child: Text("Daftar Logbook tampil di sini")),
    );
  }
}