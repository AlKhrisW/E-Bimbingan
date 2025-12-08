import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../navigation/mahasiswa_navbar_config.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';

class MahasiswaMainScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaMainScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final navItems = buildMahasiswaNavItems(user);

    return CustomBottomNavShell(
      navItems: navItems,
      heroTag: "MahasiswaNav",
    );
  }
}
