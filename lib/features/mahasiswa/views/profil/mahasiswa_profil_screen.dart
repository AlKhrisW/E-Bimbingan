import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/appbar/profile_page_appbar.dart';
import 'package:ebimbingan/features/mahasiswa/viewmodels/mahasiswa_viewmodel.dart';
import 'package:ebimbingan/features/mahasiswa/views/profil/mahasiswa_edit_profil_screen.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/data/models/user_model.dart';

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

  // Widget Header
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
        onLogout: (ctx) => context.read<MahasiswaViewModel>().handleLogout(ctx),
      ),
      body: Consumer<MahasiswaViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.mahasiswaData == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final data = vm.mahasiswaData!;
          
          // Format Tanggal
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
                // 1. Header Identitas Utama
                _buildProfileHeader(data),

                const SizedBox(height: 20),

                // Accordion 1: Data Akademik
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
                          BuildField(label: 'Program Studi', value: data.programStudi ?? '-'),
                          BuildField(label: 'Email', value: data.email),
                          BuildField(label: 'Nomor Telepon', value: data.phoneNumber ?? '-'),
                        ],
                      ),
                    ),
                  ),
                ),

                // Accordion 2: Info Magang
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                          "Informasi Magang",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        childrenPadding: const EdgeInsets.all(20),
                        children: [
                          BuildField(label: 'Lokasi Magang', value: data.placement ?? '-'),
                          BuildField(label: 'Tanggal Mulai', value: startDate),
                          BuildField(label: 'Tanggal Selesai', value: endDate),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Menu Actions
                _buildMenuButton(
                  title: "Update Data Diri",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MahasiswaEditProfilScreen()),
                    );
                  },
                ),

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