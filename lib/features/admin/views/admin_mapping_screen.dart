// lib/features/admin/views/admin_mapping_screen.dart

import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';

class AdminMappingScreen extends StatelessWidget {
  final UserModel user;
  const AdminMappingScreen({super.key, required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapping Data')),
      body: const Center(child: Text('Halaman Pemetaan Data (Admin)')),
    );
  }
}