import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/notification_page_appBar.dart';

class DosenNotifikasi extends StatelessWidget {
  final UserModel user;
  const DosenNotifikasi({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NotificationAppBar(),
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