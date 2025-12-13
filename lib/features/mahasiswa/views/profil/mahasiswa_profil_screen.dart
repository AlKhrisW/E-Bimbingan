import 'package:intl/intl.dart';
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
import 'package:ebimbingan/core/widgets/accordion/accordion_update_password.dart';
import 'package:ebimbingan/core/widgets/accordion/accordion_update_data_diri.dart';

// Import ViewModel
import '../../viewmodels/mahasiswa_viewmodel.dart';

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

  // Widget Header: Avatar & Nama
  Widget _buildProfileHeader(UserModel data) {
    String initials = data.name.isNotEmpty ? data.name[0].toUpperCase() : 'M';
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
            data.nim ?? '-',
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
        onLogout: (ctx) => context.read<MahasiswaViewModel>().handleLogout(ctx),
      ),
      body: Consumer<MahasiswaViewModel>(
        builder: (context, vm, child) {
          // Loading State
          if (vm.isLoading && vm.mahasiswaData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Error/Empty State
          if (vm.mahasiswaData == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final data = vm.mahasiswaData!;
          
          final startDate = data.startDate != null 
              ? DateFormat('dd MMMM yyyy', 'id_ID').format(data.startDate!) 
              : '-';
          final endDate = data.endDate != null 
              ? DateFormat('dd MMMM yyyy', 'id_ID').format(data.endDate!) 
              : '-';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 1. HEADER (Identitas Utama)
                _buildProfileHeader(data),

                const SizedBox(height: 10),

                // 2. ACCORDION 1: Data Akademik & Kontak (Read Only)
                AccordionWrapper(
                  title: "Detail Data Diri",
                  children: [
                    BuildField(label: 'Email', value: data.email),
                    BuildField(label: 'Program Studi', value: data.programStudi ?? '-'),
                    BuildField(label: 'Nomor Telepon', value: data.phoneNumber ?? '-'),
                  ],
                ),

                // 3. ACCORDION 2: Informasi Magang (Read Only)
                AccordionWrapper(
                  title: "Informasi Magang",
                  children: [
                    BuildField(label: 'Lokasi Magang', value: data.placement ?? '-'),
                    BuildField(label: 'Tanggal Mulai', value: startDate),
                    BuildField(label: 'Tanggal Selesai', value: endDate),
                  ],
                ),

                // 4. FORM UPDATE DATA DIRI (Nama & HP)
                UpdateDataDiri(
                  initialName: data.name,
                  initialPhone: data.phoneNumber ?? '',
                  onUpdate: (newName, newPhone) async {
                    await vm.updateProfile(name: newName, phoneNumber: newPhone);
                  },
                ),

                // 5. FORM GANTI PASSWORD
                UpdatePassword(
                  onChangePassword: (oldPass, newPass) async {
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