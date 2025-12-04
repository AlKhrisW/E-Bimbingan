import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/widgets/appbar/custom_universal_back_appBar.dart';

class DosenNotifikasi extends StatelessWidget {
  final UserModel user;
  const DosenNotifikasi({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomUniversalAppbar(judul: "Notifikasi"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Halaman Notifikasi Dosen"),
          ],
        ),
      ),
    );
  }
}