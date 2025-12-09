// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/themes/app_theme.dart';
import 'features/auth/views/splash_screen.dart';
import 'core/utils/navigation/app_navigator.dart';

// Dosen Routes
import 'package:ebimbingan/features/dosen/views/ajuan/riwayat/riwayat_detail_screen.dart';
import 'package:ebimbingan/features/dosen/views/ajuan/validasi/detail_screen.dart';
import 'package:ebimbingan/features/dosen/views/log_bimbingan/riwayat/riwayat_detail_screen.dart';
import 'package:ebimbingan/features/dosen/views/log_bimbingan/validasi/detail_screen.dart';
import 'package:ebimbingan/features/dosen/views/log_harian/detail_screen.dart';

// Auth
import 'features/auth/viewmodels/auth_viewmodel.dart';

// Admin
import 'features/admin/viewmodels/admin_viewmodel.dart';
import 'features/admin/viewmodels/admin_profile_viewmodel.dart';
import 'features/admin/viewmodels/admin_dashboard_viewmodel.dart';
import 'features/admin/viewmodels/admin_user_management_viewmodel.dart';
import 'features/admin/viewmodels/mapping/admin_dosen_list_vm.dart';
import 'features/admin/viewmodels/mapping/detail_mapping_vm.dart';

// Mahasiswa ViewModels
import 'features/mahasiswa/viewmodels/mahasiswa_viewmodel.dart';
import 'features/mahasiswa/viewmodels/log_harian_viewmodel.dart';
import 'features/mahasiswa/viewmodels/log_mingguan_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global Auth
        ChangeNotifierProvider(create: (_) => AuthViewModel()),

        // Provider Khusus Mahasiswa
        ChangeNotifierProvider(create: (_) => MahasiswaViewModel()),
        ChangeNotifierProvider(create: (_) => MahasiswaLogMingguanViewModel()),
        ChangeNotifierProvider(create: (_) => MahasiswaLogHarianViewModel()),

        // --- ADMIN ---
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => AdminProfileViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AdminUserManagementViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDosenListViewModel()),
        ChangeNotifierProvider(create: (_) => DetailMappingViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'E-Bimbingan App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          // --- AJUAN BIMBINGAN ---
          '/detail_ajuan_validasi': (context) => const DosenAjuanDetail(),
          '/detail_ajuan_riwayat': (context) => const DosenAjuanRiwayatDetail(),

          // --- LOG BIMBINGAN ---
          '/detail_log_validasi': (context) => const DosenLogbookDetail(), 
          '/detail_log_riwayat': (context) => const DosenRiwayatBimbinganDetail(),

          // --- LOGBOOK HARIAN ---
          '/detail_logbook_harian': (context) => const LogbookHarianDetail(),
        },
      ),
    );
  }
}