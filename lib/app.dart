// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';

import 'core/themes/app_theme.dart';
import 'features/auth/views/splash_screen.dart';
import 'core/utils/navigation/app_navigator.dart';

// Auth
import 'features/auth/viewmodels/auth_viewmodel.dart';

// Admin
import 'features/admin/viewmodels/admin_viewmodel.dart';
import 'features/admin/viewmodels/admin_profile_viewmodel.dart';
import 'features/admin/viewmodels/admin_dashboard_viewmodel.dart';
import 'features/admin/viewmodels/admin_user_management_viewmodel.dart';
import 'features/admin/viewmodels/mapping/admin_dosen_list_vm.dart';     // IMPORT
import 'features/admin/viewmodels/mapping/detail_mapping_vm.dart';      // IMPORT

// Dosen
import 'package:ebimbingan/features/dosen/viewmodels/dosen_profil_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_mahasiswa_list_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_bimbingan_viewmodel.dart';

// Mahasiswa ViewModels
import 'features/mahasiswa/viewmodels/mahasiswa_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global
        ChangeNotifierProvider(create: (_) => AuthViewModel()),

        // Provider Khusus Mahasiswa
        ChangeNotifierProvider(create: (_) => MahasiswaViewModel(authService: FirebaseAuthService(),userService: UserService())),

        // Provider Khusus Dosen
        ChangeNotifierProvider(create: (_) => DosenProfilViewModel(authService: FirebaseAuthService(),userService: UserService())),
        ChangeNotifierProvider(create: (_) => DosenMahasiswaViewModel(authService: FirebaseAuthService(),userService: UserService())),
        ChangeNotifierProvider(create: (_) => DosenLogbookHarianViewModel()),
        ChangeNotifierProvider(create: (_) => DosenAjuanBimbinganViewModel()),

        // Admin
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => AdminProfileViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AdminUserManagementViewModel()),

        // Mapping Admin — HANYA CREATE, JANGAN LANGSUNG LOAD!
        ChangeNotifierProvider(create: (_) => AdminDosenListViewModel()),
        ChangeNotifierProvider(create: (_) => DetailMappingViewModel()), // PENTING!
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'E-Bimbingan App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}