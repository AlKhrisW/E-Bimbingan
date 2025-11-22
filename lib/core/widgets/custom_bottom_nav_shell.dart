// lib/core/widgets/custom_bottom_nav_shell.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

// Definisi Item Navigasi Universal (Fixes "NavItem isn't defined")
class NavItem {
  final String label;
  final IconData icon;
  final Widget screen;
  final VoidCallback? onTap; // untuk modal/slider

  NavItem({
    required this.label,
    required this.icon,
    required this.screen,
    this.onTap,
  });
}

class CustomBottomNavShell extends StatefulWidget {
  final List<NavItem> navItems;
  final String heroTag;

  const CustomBottomNavShell({
    super.key,
    required this.navItems,
    required this.heroTag,
  });

  @override
  State<CustomBottomNavShell> createState() => _CustomBottomNavShellState();
}

class _CustomBottomNavShellState extends State<CustomBottomNavShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: widget.navItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          final item = widget.navItems[index];
          if (item.onTap != null) {
            item.onTap!();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        items: widget.navItems
            .map((e) => BottomNavigationBarItem(icon: Icon(e.icon), label: e.label))
            .toList(),
      ),
    );
  }
}