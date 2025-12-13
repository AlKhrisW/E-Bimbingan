// lib/features/admin/navigation/admin_navigation_config.dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_bottom_nav_shell.dart';
import '../views/dashboard/admin_dashboard_screen.dart';
import '../views/admin_users_screen.dart';
import '../views/mapping/admin_mapping_screen.dart';
import '../views/admin_profile_screen.dart';
import '../../../../data/models/user_model.dart';

// Tambahkan parameter callback untuk navigasi antar-tab
List<NavItem> buildAdminNavItems(
    UserModel user, Function(int) onNavigateToTab) {
  return [
    NavItem( // Index 0
      label: 'Beranda',
      icon: Icons.home_filled,
      // Berikan callback ke Dashboard
      screen: AdminDashboardScreen(
        user: user,
        onNavigateToTab: onNavigateToTab, 
      ),
    ),
    NavItem( // Index 1
      label: 'Users',
      icon: Icons.manage_accounts_outlined,
      screen: AdminUsersScreen(user: user),
    ),
    NavItem( // Index 2
      label: 'Mapping',
      icon: Icons.map_outlined,
      screen: const AdminMappingScreen(),
    ),
    NavItem( // Index 3
      label: 'Akun',
      icon: Icons.person_outline,
      screen: AdminProfileScreen(user: user),
    ),
  ];
}