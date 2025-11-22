import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/user_model.dart';
import '../viewmodels/dosen_viewmodel.dart';
import '../../../core/widgets/profile_page_appBar.dart';

class DosenProfil extends StatelessWidget {
  final UserModel user;
  const DosenProfil({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DosenViewModel>(context, listen: false);

    return Scaffold(
      appBar: ProfilePageAppbar(
        onLogout: viewModel.handleLogout,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Halaman Profil Dosen"),
          ],
        ),
      ),
    );
  }
}