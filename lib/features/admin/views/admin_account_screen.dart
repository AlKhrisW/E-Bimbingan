// lib/features/admin/views/admin_account_screen.dart

import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';

class AdminAccountScreen extends StatelessWidget {
  final UserModel user;
  const AdminAccountScreen({super.key, required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun Admin')),
      body: const Center(child: Text('Halaman Profil dan Pengaturan Admin')),
    );
  }
}