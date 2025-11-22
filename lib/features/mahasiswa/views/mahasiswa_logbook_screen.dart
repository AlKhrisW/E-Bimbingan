import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class MahasiswaLogbookScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaLogbookScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook Mingguan"),
      ),
      body: Center(
        child: Text(
          "Halaman Logbook Mingguan\nNama: ${user.name ?? '-'}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
