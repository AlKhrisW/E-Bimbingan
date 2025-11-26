import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/profile_page_appBar.dart';
import 'package:ebimbingan/core/widgets/custom_profile_card.dart';
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

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenViewModel>(builder: (context, vm, child) {
      if (vm.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      if (vm.dosenData == null) return const Scaffold(body: Center(child: Text('Data tidak ditemukan')));

      final data = vm.dosenData!;

      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: ProfilePageAppbar(onLogout: vm.handleLogout),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ProfileCardWidget(
            name: data.name,
            onEditPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DosenEditProfil()));
            },
            fields: [
              _buildField('Email', data.email),
              _buildField('NIP/NIDN', data.nip ?? '-'),
              _buildField('Jabatan Fungsional', data.jabatan ?? '-'),
              _buildField('Nomor Telepon', data.phoneNumber ?? '-'),
            ],
          ),
        ),
      );
    });
  }
}