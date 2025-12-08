// lib/features/dosen/views/dosen_main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models & Nav
import '../../../data/models/user_model.dart';
import '../navigation/dosen_navigation_config.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';

// Dosen ViewModels
import 'package:ebimbingan/features/dosen/viewmodels/dosen_profil_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_riwayat_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_riwayat_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_mahasiswa_list_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';

class DosenMain extends StatelessWidget {
  final UserModel user;

  const DosenMain({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Ambil item navigasi
    final List<NavItem> navItems = DosenNavigationConfig.items(user);

    // BUNGKUS DENGAN MULTIPROVIDER
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DosenProfilViewModel()),
        ChangeNotifierProvider(create: (_) => DosenMahasiswaViewModel()),
        ChangeNotifierProvider(create: (_) => DosenLogbookHarianViewModel()),
        ChangeNotifierProvider(create: (_) => DosenAjuanViewModel()),
        ChangeNotifierProvider(create: (_) => DosenRiwayatAjuanViewModel()),
        ChangeNotifierProvider(create: (_) => DosenBimbinganViewModel()),
        ChangeNotifierProvider(create: (_) => DosenRiwayatBimbinganViewModel()),
      ],
      child: CustomBottomNavShell(
        navItems: navItems,
        heroTag: 'DoseNav',
      ),
    );
  }
}