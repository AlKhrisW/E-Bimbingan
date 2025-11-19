// lib/features/admin/views/user_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Import widget baru
import '../widgets/detail_info_row.dart'; 
import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import 'register_user_screen.dart'; 

class UserDetailScreen extends StatelessWidget {
  final UserModel user;
  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Tentukan detail spesifik berdasarkan role
    List<Widget> specificDetails = [];
    String subTitle = '';

    if (user.role == 'mahasiswa') {
      subTitle = 'Mahasiswa - ${user.programStudi}';
      specificDetails = [
        DetailInfoRow(label: 'NIM', value: user.nim ?? 'N/A', icon: Icons.badge),
        DetailInfoRow(label: 'Penempatan Magang', value: user.placement ?? 'Belum Ditentukan', icon: Icons.business),
        DetailInfoRow(label: 'Tgl Mulai Magang', value: user.startDate != null ? DateFormat('dd MMMM yyyy').format(user.startDate!) : 'N/A', icon: Icons.calendar_month),
        DetailInfoRow(label: 'Dosen Pembimbing UID', value: user.dosenUid ?? 'Belum Direlasikan', icon: Icons.people),
      ];
    } else if (user.role == 'dosen') {
      subTitle = 'Dosen - ${user.jabatan}';
      specificDetails = [
        DetailInfoRow(label: 'NIP', value: user.nip ?? 'N/A', icon: Icons.badge),
        DetailInfoRow(label: 'Jabatan Fungsional', value: user.jabatan ?? 'N/A', icon: Icons.work),
      ];
    } else {
      subTitle = 'Administrator Sistem';
      specificDetails = [
        DetailInfoRow(label: 'NIP/NIM', value: user.nim ?? user.nip ?? 'N/A', icon: Icons.badge),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengguna', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Tombol Edit di Header
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => RegisterUserScreen(userToEdit: user)),
              ).then((_) => Navigator.pop(context)); 
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER INFO ---
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 10),
                  Text(user.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(subTitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            ),
            const Divider(height: 40),

            // --- DATA UMUM ---
            Text('Informasi Dasar Akun', style: Theme.of(context).textTheme.titleLarge),
            DetailInfoRow(label: 'E-Mail', value: user.email, icon: Icons.email),
            DetailInfoRow(label: 'No. Telepon', value: user.phoneNumber ?? 'N/A', icon: Icons.phone),
            DetailInfoRow(label: 'Program Studi', value: user.programStudi ?? 'N/A', icon: Icons.school),
            const Divider(height: 30),

            // --- DATA SPESIFIK ROLE ---
            if (specificDetails.isNotEmpty) ...[
              Text('Detail Tugas & Penempatan', style: Theme.of(context).textTheme.titleLarge),
              ...specificDetails,
            ],
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}