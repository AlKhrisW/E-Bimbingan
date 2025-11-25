import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/profile_page_appBar.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_profile_card.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_viewmodel.dart';
import 'package:ebimbingan/features/dosen/views/dosen_edit_profil_screen.dart';

class DosenProfil extends StatefulWidget {
  const DosenProfil({super.key});

  @override
  State<DosenProfil> createState() => _DosenProfilState();
}

class _DosenProfilState extends State<DosenProfil> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DosenViewModel>().loadDosenData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (vm.dosenData == null) {
          return const Scaffold(body: Center(child: Text('Data tidak tersedia')));
        }

        final data = vm.dosenData!;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: ProfilePageAppbar(onLogout: vm.handleLogout),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ProfileCard(
              name: data.name,
              email: data.email,
              nip: data.nip ?? '-',
              jabatan: data.jabatan ?? '-',
              phoneNumber: data.phoneNumber ?? '-',
              onEditPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DosenEditProfil()));
              },
            ),
          ),
        );
      },
    );
  }
}