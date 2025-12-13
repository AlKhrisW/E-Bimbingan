import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Model & Theme
import '../../../../data/models/user_model.dart';
import '../../../../core/themes/app_theme.dart';

// Import Widget UI
import '../../../../core/widgets/appbar/profile_page_appbar.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/accordion/custom_accordion.dart';

// Import Widget Form
import 'package:ebimbingan/core/widgets/accordion/accordion_update_data_diri.dart';
import 'package:ebimbingan/core/widgets/accordion/accordion_update_password.dart';

// Import ViewModel
import '../../viewmodels/dosen_profil_viewmodel.dart';

class DosenProfil extends StatefulWidget {
  const DosenProfil({super.key});

  @override
  State<DosenProfil> createState() => _DosenProfilState();
}

class _DosenProfilState extends State<DosenProfil> {
  @override
  void initState() {
    super.initState();
    // Load data dosen saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DosenProfilViewModel>().loadDosenData();
    });
  }

  // Header Profil (Foto, Nama, NIP)
  Widget _buildProfileHeader(UserModel data) {
    String initials = data.name.isNotEmpty ? data.name[0].toUpperCase() : 'D';
    if (data.name.split(' ').length > 1) {
      initials = data.name.split(' ').map((e) => e[0]).take(2).join('').toUpperCase();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            data.nip ?? '-',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ProfilePageAppbar(
        onLogout: (ctx) => context.read<DosenProfilViewModel>().handleLogout(ctx),
      ),
      body: Consumer<DosenProfilViewModel>(
        builder: (context, vm, child) {
          // Loading Awal (saat data null)
          if (vm.isLoading && vm.dosenData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (vm.dosenData == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final data = vm.dosenData!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 1. HEADER
                _buildProfileHeader(data),

                const SizedBox(height: 10),

                // 2. READ-ONLY DATA (Jabatan, Email, Prodi)
                AccordionWrapper(
                  title: "Detail Data Diri",
                  children: [
                    BuildField(label: 'Email', value: data.email),
                    BuildField(label: 'Jabatan Fungsional', value: data.jabatan ?? '-'),
                    BuildField(label: 'Nomor Telepon', value: data.phoneNumber ?? '-'),
                  ],
                ),

                // 3. FORM UPDATE DATA DIRI
                UpdateDataDiri(
                  initialName: data.name,
                  initialPhone: data.phoneNumber ?? '',
                  onUpdate: (newName, newPhone) async {
                    // Integrasi ke ViewModel
                    await vm.updateProfile(name: newName, phoneNumber: newPhone);
                  },
                ),

                // 4. FORM GANTI PASSWORD
                UpdatePassword(
                  onChangePassword: (oldPass, newPass) async {
                    // Integrasi ke ViewModel (akan melakukan cek password lama)
                    await vm.changePassword(oldPass, newPass);
                  },
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}