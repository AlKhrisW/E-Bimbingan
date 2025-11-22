import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class DosenProgres extends StatelessWidget {
  final UserModel user;
  const DosenProgres({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kelola Progress Mahasiswa")),
      body: Center(child: Text("Daftar Progress Mahasiswa tampil di sini")),
    );
  }
}