import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/appbar/profile_page_appbar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_profil_viewmodel.dart';
import 'package:ebimbingan/features/dosen/views/profile/dosen_edit_profil_screen.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart'; 
import 'package:ebimbingan/data/models/user_model.dart';

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
      context.read<DosenProfilViewModel>().loadDosenData();
    });
  }

  // Widget Header
  Widget _buildProfileHeader(UserModel data) {
    String initials = data.name.isNotEmpty ? data.name[0].toUpperCase() : 'U';
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

  // Widget Tombol Menu
  Widget _buildMenuButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), 
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
          if (vm.isLoading) {
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
                // 1. Header (Avatar & Nama)
                _buildProfileHeader(data),

                const SizedBox(height: 20),

                // 2. Accordion Data Diri
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ExpansionTile(
                        // Style saat tertutup (Collapsed)
                        collapsedBackgroundColor: AppTheme.primaryColor,
                        collapsedIconColor: Colors.white,
                        collapsedTextColor: Colors.white,
                        
                        // Style saat terbuka (Expanded)
                        backgroundColor: Colors.white,
                        iconColor: AppTheme.primaryColor,
                        textColor: AppTheme.primaryColor,

                        // Bentuk Border
                        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: AppTheme.primaryColor, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        title: const Text(
                          "Detail Data Diri",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        
                        childrenPadding: const EdgeInsets.all(20),
                        children: [
                          BuildField(label: 'Email', value: data.email),
                          BuildField(label: 'Jabatan Fungsional', value: data.jabatan ?? '-'),
                          BuildField(label: 'Nomor Telepon', value: data.phoneNumber ?? '-'),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Tombol Update Profil
                _buildMenuButton(
                  title: "Update Data Diri",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: DosenEditProfil(),
                        ),
                      ),
                    );
                  },
                ),

                // 4. Tombol Ganti Password
                _buildMenuButton(
                  title: "Ganti Password",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fitur Ganti Password akan segera hadir")),
                    );
                  },
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}