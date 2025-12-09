import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import '../custom_button_back.dart';

class CustomUniversalAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String judul;
  const CustomUniversalAppbar({super.key, required this.judul});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      surfaceTintColor: AppTheme.backgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: const CustomBackButton(),
      title: Text(
        judul,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}