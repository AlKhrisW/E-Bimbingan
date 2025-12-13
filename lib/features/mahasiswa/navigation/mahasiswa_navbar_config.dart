// lib/features/mahasiswa/widgets/mahasiswa_navbar_config.dart

import 'package:ebimbingan/core/widgets/custom_badge_count.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';
import '../../../data/models/user_model.dart';

import '../views/dashboard/mahasiswa_dashboard.dart';
import '../views/ajuanBimbingan/mahasiswa_ajuan_bimbingan_screen.dart'; 
import '../views/logHarian/mahasiswa_log_harian_screen.dart';
import '../views/logMingguan/mahasiswa_log_mingguan_screen.dart';
import '../views/profil/mahasiswa_profil_screen.dart';

import 'package:ebimbingan/features/mahasiswa/viewmodels/log_mingguan_viewmodel.dart';

// CONFIG NAVIGASI UNTUK ROLE MAHASISWA
List<NavItem> buildMahasiswaNavItems(UserModel user) {
  return [
    NavItem(
      label: "Beranda",
      icon: Icons.home,
      screen: MahasiswaDashboardScreen(),
    ),

    NavItem(
      label: "Ajuan",
      icon: Icons.assignment_outlined,
       screen: MahasiswaAjuanBimbinganScreen(),
    ),

    NavItem(
      label: "Log-Mingguan",
      icon: Icons.book_outlined,
      screen: MahasiswaLogMingguanScreen(),
      badge: Consumer<MahasiswaLogMingguanViewModel>(
        builder: (context, vm, child) {
          return StreamBuilder<int>(
            stream: vm.unreadCountStream,
            initialData: 0,
            builder: (context, snapshot) {
              return CountBadge(
                count: snapshot.data ?? 0,
              );
            },
          );
        },
      ),
    ),

    NavItem(
      label: "Log-Harian",
      icon: Icons.timeline,
      screen: MahasiswaLogHarianScreen(),
    ),

    NavItem(
      label: "Profil",
      icon: Icons.person,
      screen: MahasiswaProfilScreen(),
    ),
  ];
}
