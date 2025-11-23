// lib/features/admin/admin_navbar_config.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_bottom_nav_shell.dart'; 
import '../views/admin_dashboard.dart'; 
import '../views/admin_users_screen.dart'; 
import '../views/admin_mapping_screen.dart'; 
import '../views/admin_profile_screen.dart'; 
import '../../../../data/models/user_model.dart';

List<NavItem> buildAdminNavItems(UserModel user) {
  return [
    NavItem(
      label: 'Beranda',
      icon: Icons.home_filled,
      screen: AdminDashboard(user: user), 
    ),
    NavItem(
      label: 'Users',
      icon: Icons.manage_accounts_outlined,
      screen: AdminUsersScreen(user: user),
    ),
    NavItem(
      label: 'Mapping',
      icon: Icons.map_outlined,
      screen: AdminMappingScreen(user: user),
    ),
    NavItem(
      label: 'Akun',
      icon: Icons.person_outline,
      screen: AdminProfileScreen(user: user),
    ),
  ];
}