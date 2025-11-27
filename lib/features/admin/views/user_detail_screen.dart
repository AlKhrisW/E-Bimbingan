// lib/features/admin/views/user_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/custom_button_back.dart'; 
import '../widgets/detail_info_row.dart';
import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import 'register_user_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // tentukan detail spesifik berdasarkan role
    List<Widget> specificDetails = [];
    String subTitle = '';

    if (user.role == 'mahasiswa') {
      subTitle = 'Mahasiswa - ${user.programStudi ?? 'N/A'}';
      specificDetails = [
        DetailInfoRow(label: 'NIM', value: user.nim ?? 'N/A', icon: Icons.badge),
        DetailInfoRow(
          label: 'Penempatan Magang',
          value: user.placement ?? 'Belum Ditentukan',
          icon: Icons.business,
        ),
        DetailInfoRow(
          label: 'Tgl Mulai Magang',
          value: user.startDate != null
              ? DateFormat('dd MMMM yyyy').format(user.startDate!)
              : 'N/A',
          icon: Icons.calendar_month,
        ),
        DetailInfoRow(
          label: 'Dosen Pembimbing UID',
          value: user.dosenUid ?? 'Belum Direlasikan',
          icon: Icons.people,
        ),
      ];
    } else if (user.role == 'dosen') {
      subTitle = 'Dosen - ${user.jabatan ?? 'N/A'}';
      specificDetails = [
        DetailInfoRow(label: 'NIP', value: user.nip ?? 'N/A', icon: Icons.badge),
        DetailInfoRow(
          label: 'Jabatan Fungsional',
          value: user.jabatan ?? 'N/A',
          icon: Icons.work,
        ),
      ];
    } else {
      // admin atau role lain
      subTitle = 'Administrator Sistem';
      specificDetails = [
        DetailInfoRow(
          label: 'NIP/NIM',
          value: user.nim ?? user.nip ?? 'N/A',
          icon: Icons.badge,
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(), // custom back button yang cantik & konsisten
        title: const Text(
          'Detail Pengguna',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // tombol edit
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => RegisterUserScreen(userToEdit: user),
                    ),
                  )
                  .then((_) => Navigator.pop(context)); // refresh setelah edit
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header profil
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subTitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),

            const Divider(height: 40),

            // informasi dasar akun
            Text(
              'Informasi Dasar Akun',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            DetailInfoRow(label: 'E-Mail', value: user.email, icon: Icons.email),
            DetailInfoRow(
              label: 'No. Telepon',
              value: user.phoneNumber ?? 'N/A',
              icon: Icons.phone,
            ),

            // program studi hanya untuk mahasiswa
            if (user.isMahasiswa)
              DetailInfoRow(
                label: 'Program Studi',
                value: user.programStudi ?? 'N/A',
                icon: Icons.school,
              ),

            const Divider(height: 30),

            // detail spesifik role
            if (specificDetails.isNotEmpty) ...[
              Text(
                'Detail Tugas & Penempatan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...specificDetails,
            ],

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}