// lib/features/dosen/views/dosen_home.dart

import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../navigation/dosen_navigation_config.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';

class DosenMain extends StatelessWidget {
  final UserModel user;

  const DosenMain({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Ambil semua item navigasi untuk dosen
    final List<NavItem> navItems = DosenNavigationConfig.items(user); 

    return CustomBottomNavShell(
      navItems: navItems,
      heroTag: 'DoseNav',
    );
  }
}