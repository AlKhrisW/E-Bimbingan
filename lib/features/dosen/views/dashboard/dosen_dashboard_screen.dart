// lib/features/dosen/views/dosen_dashboard.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/dashboard_page_appBar.dart';
import '../../../../data/models/user_model.dart';
import 'dosen_notifikasi_screen.dart';

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
              builder: (context) => DosenNotifikasi(user: user),
            ),
          );
        },
      ),
      body: const Center(child: Text("Dashboard Dosen")),
    );
  }
}