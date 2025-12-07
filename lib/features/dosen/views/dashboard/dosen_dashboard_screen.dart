// lib/features/dosen/views/dosen_dashboard.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/appbar/dashboard_page_appBar.dart';
import '../../../../data/models/user_model.dart';
import 'package:ebimbingan/features/notifikasi/views/notifikasi_screen.dart';

class DosenDashboard extends StatelessWidget {
  final UserModel user; 
  const DosenDashboard({super.key, required this.user}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardPageAppBar(
        name: user.name,
        placement: user.jabatan ?? "Dosen",
        photoUrl: null,
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationPage(),
            ),
          );
        },
      ),
      body: const Center(child: Text("Dashboard Dosen")),
    );
  }
}