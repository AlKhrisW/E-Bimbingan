// lib/features/mahasiswa/widgets/mahasiswa_navbar_config.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';
import '../../../data/models/user_model.dart';
import '../views/mahasiswa_dashboard.dart';
import '../widgets/mahasiswa_bimbingan_modal.dart';
import '../views/mahasiswa_riwayat_screen.dart';
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
      label: "Bimbingan",
      icon: Icons.assignment,
      screen: Scaffold(body: SizedBox.shrink()),
      onTap: () {
        MahasiswaBimbinganModal.show(user);
      },
    ),
    NavItem(
      label: "Riwayat",
      icon: Icons.history,
      screen: MahasiswaRiwayatScreen(user: user),
    ),
    NavItem(
      label: "Profil",
      icon: Icons.person,
      screen: MahasiswaProfilScreen(user: user),
    ),
  ];
}
