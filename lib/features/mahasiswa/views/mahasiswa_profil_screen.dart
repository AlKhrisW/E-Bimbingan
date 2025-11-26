import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/profile_page_appBar.dart';
import 'package:ebimbingan/core/widgets/custom_profile_card.dart';
import 'package:ebimbingan/features/mahasiswa/viewmodels/mahasiswa_viewmodel.dart';
import 'package:ebimbingan/features/mahasiswa/views/mahasiswa_edit_profil_screen.dart';

class MahasiswaProfilScreen extends StatefulWidget {
  const MahasiswaProfilScreen({super.key});

  @override
  State<MahasiswaProfilScreen> createState() => _MahasiswaProfilScreenState();
}

class _MahasiswaProfilScreenState extends State<MahasiswaProfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MahasiswaViewModel>().loadmahasiswaData();
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
    return Consumer<MahasiswaViewModel>(builder: (context, vm, child) {
      if (vm.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      if (vm.mahasiswaData == null) return const Scaffold(body: Center(child: Text('Data tidak ditemukan')));

      final data = vm.mahasiswaData!;

      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: ProfilePageAppbar(onLogout: vm.handleLogout),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ProfileCardWidget(
            name: data.name,
            onEditPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MahasiswaEditProfilScreen()));
            },
            fields: [
              _buildField('Email', data.email),
              _buildField('NIM', data.nim ?? '-'),
              _buildField('Program Studi', data.programStudi ?? '-'),
              _buildField('Nomor Telepon', data.phoneNumber ?? '-'),
            ],
          ),
        ),
      );
    });
  }
}