import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class DosenProfil extends StatelessWidget {
  final UserModel user;

  const DosenProfil({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil Dosen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: ${user.name}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Email: ${user.email}", style: TextStyle(fontSize: 18)),
            // Tambahkan informasi profil lainnya sesuai kebutuhan
          ],
        ),
      ),
    );
  }
}