import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import 'package:ebimbingan/core/widgets/custom_universal_back_appBar.dart';

class DosenProgres extends StatelessWidget {
  final UserModel user;
  const DosenProgres({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomUniversalAppbar(judul: "Progress Mahasiswa"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Halaman Progress Mahasiswa"),
          ],
        ),
      ),
    );
  }
}