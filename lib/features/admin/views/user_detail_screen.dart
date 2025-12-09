import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/custom_button_back.dart';
import '../widgets/detail/detail_outline_field.dart'; // Widget detail modern
import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import 'register_user_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Tentukan label dan nilai NIM/NIP
    String nimNipLabel = user.role == 'dosen' ? 'NIP' : 'NIM';
    String nimNipValue = user.nim ?? user.nip ?? 'N/A';

    // Tentukan detail spesifik untuk Magang/Dosen (yang bukan info dasar)
    List<Widget> specificDetails = [];
    String subTitle = '';

    if (user.role == 'mahasiswa') {
      subTitle = 'Mahasiswa - ${user.programStudi ?? 'N/A'}';
      specificDetails = [
        // Hanya informasi Magang/Pembimbing di sini
        DetailOutlineField(
          label: 'Penempatan Magang',
          value: user.placement ?? 'Belum Ditentukan',
          icon: Icons.business,
        ),
        DetailOutlineField(
          label: 'Tgl Mulai Magang',
          value: user.startDate != null
              ? DateFormat('dd MMMM yyyy').format(user.startDate!)
              : 'N/A',
          icon: Icons.calendar_month,
        ),
        DetailOutlineField(
          label: 'Dosen Pembimbing UID',
          value: user.dosenUid ?? 'Belum Direlasikan',
          icon: Icons.people,
        ),
      ];
    } else if (user.role == 'dosen') {
      subTitle = 'Dosen - ${user.jabatan ?? 'N/A'}';
      specificDetails = [
        // Hanya informasi Jabatan di sini
        DetailOutlineField(
          label: 'Jabatan Fungsional',
          value: user.jabatan ?? 'N/A',
          icon: Icons.work,
        ),
      ];
    } else {
      // admin atau role lain
      subTitle = 'Administrator Sistem';
      // specificDetails kosong
    }

    // --- INFORMASI DASAR AKUN (Urutan Baru) ---
    List<Widget> generalDetails = [
      // 1. Role
      DetailOutlineField(
        label: 'Role',
        value: user.role.substring(0, 1).toUpperCase() + user.role.substring(1),
        icon: Icons.assignment_ind,
      ),

      // 2. NIM/NIP (Memastikan label dan value benar)
      DetailOutlineField(
        label: nimNipLabel,
        value: nimNipValue,
        icon: Icons.badge,
      ),

      // 3. Program Studi (Hanya untuk Mahasiswa)
      if (user.role == 'mahasiswa')
        DetailOutlineField(
          label: 'Program Studi',
          value:
              user.programStudi ??
              'N/A', // <-- Pastikan ini memanggil programStudi
          icon: Icons.school,
        ),

      // 4. Email
      DetailOutlineField(
        label: 'E-Mail',
        value: user.email,
        icon: Icons.email,
      ), // <-- Pastikan ini memanggil email
      // 5. No. Telepon
      DetailOutlineField(
        label: 'No. Telepon',
        value:
            user.phoneNumber ?? 'N/A', // <-- Pastikan ini memanggil phoneNumber
        icon: Icons.phone,
      ),
    ];
    // ----------------------------------------

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        centerTitle: true,
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RegisterUserScreen(userToEdit: user),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profil
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subTitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 40),

            // Informasi Dasar Akun
            Text(
              'Informasi Dasar Akun',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // List Informasi Dasar (Sesuai Urutan Baru)
            ...generalDetails,

            const Divider(height: 30),

            // detail spesifik role
            if (specificDetails.isNotEmpty) ...[
              Text(
                user.role == 'mahasiswa'
                    ? 'Detail Magang & Pembimbing'
                    : 'Detail Fungsional Dosen',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...specificDetails,
            ],

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
