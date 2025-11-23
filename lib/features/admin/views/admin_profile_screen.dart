// lib/features/admin/views/admin_account_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/user_model.dart';
import '../viewmodels/admin_viewmodel.dart';
import '../../../core/widgets/profile_page_appBar.dart';

class AdminProfileScreen extends StatelessWidget {
  final UserModel user;

  const AdminProfileScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    // ambil viewmodel admin (mirip dosen)
    final viewModel = Provider.of<AdminViewModel>(context, listen: false);

    return Scaffold(
      // Samakan: gunakan AppBar custom (jika sudah ada)
      appBar: ProfilePageAppbar(
        onLogout: viewModel.handleLogout, // samakan dengan pola dosen
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (mirip versi dosen)
            Text(
              "Halaman Profil Admin",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Tambahkan info user (karena sudah ada UserModel)
            Text("Nama: ${user.name}"),
            Text("Email: ${user.email}"),
            const SizedBox(height: 20),

            // Footer atau note
            const Text("Pengaturan dan informasi administrator."),
          ],
        ),
      ),
    );
  }
}
