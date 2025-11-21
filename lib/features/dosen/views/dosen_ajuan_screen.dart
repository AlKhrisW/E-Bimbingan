import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class DosenAjuan extends StatelessWidget {
  final UserModel user;
  const DosenAjuan({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kelola Ajuan Bimbingan")),
      body: Center(child: Text("Daftar Ajuan Bimbingan tampil di sini")),
    );
  }
}