// lib/features/dosen/views/dosen_dashboard.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/dashboard_page_appBar.dart';
import '../../../data/models/user_model.dart';

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
        onNotificationTap: () {},
      ),
      body: const Center(child: Text("Dashboard Dosen")),
    );
  }
}