// lib/features/dosen/config/dosen_navigation_config.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';
import '../../../data/models/user_model.dart';

import '../views/dosen_dashboard_screen.dart';
import '../views/dosen_profil_screen.dart';
import '../widgets/dosen_bimbingan_modal.dart';
import '../widgets/dosen_riwayat_modal.dart';

class DosenNavigationConfig {
  static List<NavItem> items(UserModel user) => [
        NavItem(
          label: 'Beranda',
          icon: Icons.home_outlined,
          screen: DosenDashboard(user: user),
        ),
        NavItem(
          label: 'Bimbingan',
          icon: Icons.supervised_user_circle_outlined,
          screen: const SizedBox(),
          onTap: () => BimbinganModal.show(user),
        ),
        NavItem(
          label: 'Riwayat',
          icon: Icons.history_outlined,
          screen: const SizedBox(),
          onTap: () => RiwayatModal.show(user),
        ),
        NavItem(
          label: 'Profil',
          icon: Icons.person_outline,
          screen: DosenProfil(user: user),
        ),
      ];
}