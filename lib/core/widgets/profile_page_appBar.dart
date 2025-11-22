import 'package:flutter/material.dart';
import 'logout_bottom_sheet.dart';
import '../themes/app_theme.dart';

class ProfilePageAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Future<void> Function(BuildContext context) onLogout;

  const ProfilePageAppbar({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      centerTitle: true,
      elevation: 0,

      title: const Text(
        "Profil",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,
        ),
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: AppTheme.primaryColor),
          onPressed: () {
            showLogoutBottomSheet(
              context: context,
              onConfirm: () => onLogout(context),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}