// lib/features/dosen/config/dosen_navigation_config.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';
import '../../../data/models/user_model.dart';

import '../views/dashboard/dosen_dashboard_screen.dart';
import '../views/ajuan/list_screen.dart';
import '../views/profile/dosen_profil_screen.dart';
import '../widgets/dosen_riwayat_modal.dart';

class DosenNavigationConfig {
  static List<NavItem> items(UserModel user) => [
    NavItem(
      label: 'Beranda',
      icon: Icons.home_filled,
      screen: DosenDashboard(user: user),
    ),
    NavItem(
      label: 'Ajuan',
      icon: Icons.pending_actions_outlined,
      screen: DosenAjuan(),
    ),
    NavItem(
      label: 'Bimbingan',
      icon: Icons.menu_book,
      screen: const SizedBox(),
      onTap: () => RiwayatModal.show(),
    ),
    NavItem(
      label: 'Profil',
      icon: Icons.person_outline,
      screen: DosenProfil(),
    ),
  ];
}