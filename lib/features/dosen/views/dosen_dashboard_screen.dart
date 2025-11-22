// lib/features/dosen/views/dosen_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/user_model.dart';
import '../../auth/views/login_page.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class DosenDashboard extends StatelessWidget {
  final UserModel user; 
  const DosenDashboard({super.key, required this.user}); 

  void _handleLogout(BuildContext context) async {
    // Panggil logic Logout
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    await viewModel.logout();
    
    // Kembali ke halaman Login dan membersihkan semua rute
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Dosen (${user.name})'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          // TOMBOL LOGOUT (STANDAR UI/UX)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(child: Text('Halaman Monitoring Approval (Dosen)', style: TextStyle(fontSize: 20, color: Colors.blue.shade800))),
    );
  }
}