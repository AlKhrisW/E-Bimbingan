// lib/features/dosen/config/dosen_navigation_config.dart

import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';

import '../views/profile/dosen_profil_screen.dart';
import '../views/ajuan/dosen_ajuan_main_screen.dart';
import '../views/dashboard/dosen_dashboard_screen.dart';
import '../views/log_bimbingan/dosen_bimbingan_main_screen.dart';
import 'package:ebimbingan/features/dosen/views/log_harian/mahasiswa_list_screen.dart';

class DosenNavigationConfig {
  static List<NavItem> items(UserModel user) => [
    NavItem(
      label: 'Beranda',
      icon: Icons.home_filled,
      screen: DosenDashboard(user: user),
    ),
    NavItem(
      label: 'Ajuan',
      icon: Icons.assignment_outlined,
      screen: DosenAjuanMainScreen(),
    ),
    NavItem(
      label: 'Log-Bimbingan',
      icon: Icons.menu_book_outlined,
      screen: DosenBimbinganMainScreen(),
    ),
    NavItem(
      label: 'Log-Harian',
      icon: Icons.calendar_month_outlined,
      screen: DosenProgres(),
    ),
    NavItem(
      label: 'Profil',
      icon: Icons.person_outline,
      screen: DosenProfil(),
    ),
  ];
}