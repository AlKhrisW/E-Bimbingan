// lib/features/admin/views/admin_main_screen.dart

import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../navigation/admin_navigation_config.dart'; 
import '../../../core/widgets/custom_bottom_nav_shell.dart';


class AdminMainScreen extends StatelessWidget {
  final UserModel user;
  const AdminMainScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
  
    final List<NavItem> navItems = buildAdminNavItems(user); 

    return CustomBottomNavShell(
      navItems: navItems,
      heroTag: 'AdminNav',
    );
  }
}