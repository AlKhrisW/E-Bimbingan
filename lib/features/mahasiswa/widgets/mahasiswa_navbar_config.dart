// lib/features/mahasiswa/widgets/mahasiswa_navbar_config.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';
import '../../../data/models/user_model.dart';

import '../views/mahasiswa_dashboard.dart';
import '../views/mahasiswa_ajuan_screen.dart';
import '../views/mahasiswa_laporan_screen.dart';
import '../views/mahasiswa_logbook_screen.dart';
import '../views/mahasiswa_profil_screen.dart';

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
      screen: MahasiswaLaporanScreen(user: user),
    ),

    NavItem(
      label: "Ajuan",
      icon: Icons.assignment_outlined,
      screen: MahasiswaAjuanScreen(user: user),
    ),

    NavItem(
      label: "Bimbingan",
      icon: Icons.book_outlined,
      screen: MahasiswaLogbookScreen(user: user),
    ),

    NavItem(
      label: "Profil",
      icon: Icons.person,
      screen: MahasiswaProfilScreen(),
    ),
  ];
}
