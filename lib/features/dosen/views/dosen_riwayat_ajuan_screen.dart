import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class DosenRiwayatAjuan extends StatelessWidget {
  final UserModel user;
  const DosenRiwayatAjuan({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Pengajuan")),
      body: Center(child: Text("Daftar Pengajuan tampil di sini")),
    );
  }
}