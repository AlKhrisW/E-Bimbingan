// lib/features/mahasiswa/widgets/mahasiswa_navbar_config.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';
import '../../../data/models/user_model.dart';

import '../views/dashboard/mahasiswa_dashboard.dart';
import '../views/ajuanBimbingan/mahasiswa_ajuan_bimbingan_screen.dart'; 
import '../views/logHarian/mahasiswa_log_harian_screen.dart';
import '../views/logMingguan/mahasiswa_log_mingguan_screen.dart';
import '../views/profil/mahasiswa_profil_screen.dart';

// CONFIG NAVIGASI UNTUK ROLE MAHASISWA
List<NavItem> buildMahasiswaNavItems(UserModel user) {
  return [
    NavItem(
      label: "Beranda",
      icon: Icons.home,
      screen: MahasiswaDashboard(user: user),
    ),

    NavItem(
      label: "Progress",
      icon: Icons.timeline,
      screen: MahasiswaLogHarianScreen(),
    ),

    NavItem(
      label: "Ajuan",
      icon: Icons.assignment_outlined,
       screen: RiwayatAjuanScreen(user: user),
    ),

    NavItem(
      label: "Bimbingan",
      icon: Icons.book_outlined,
      screen: MahasiswaLogMingguanScreen(),
    ),

    NavItem(
      label: "Profil",
      icon: Icons.person,
      screen: MahasiswaProfilScreen(),
    ),
  ];
}
