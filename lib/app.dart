// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/themes/app_theme.dart';
import 'features/auth/views/splash_screen.dart';
import 'core/utils/navigation/app_navigator.dart';

// Mahasiswa Routes
import 'package:ebimbingan/features/mahasiswa/views/logHarian/detail_log_harian_screen.dart';
import 'package:ebimbingan/features/mahasiswa/views/logMingguan/update_log_mingguan_screen.dart';
import 'package:ebimbingan/features/mahasiswa/views/logMingguan/detail_log_mingguan_screen.dart';
import 'package:ebimbingan/features/mahasiswa/views/ajuanBimbingan/detail_ajuan_bimbingan_screen.dart';

// Dosen Routes
import 'package:ebimbingan/features/dosen/views/log_harian/detail_screen.dart';
import 'package:ebimbingan/features/dosen/views/ajuan/validasi/detail_screen.dart';
import 'package:ebimbingan/features/dosen/views/ajuan/riwayat/riwayat_detail_screen.dart';
import 'package:ebimbingan/features/dosen/views/log_bimbingan/validasi/detail_screen.dart';
import 'package:ebimbingan/features/dosen/views/log_bimbingan/riwayat/riwayat_detail_screen.dart';

// Global Viewmodels
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/notifikasi/viewmodels/notifikasi_viewmodel.dart';

// Mahasiswa Viewmodels
import 'features/mahasiswa/viewmodels/mahasiswa_viewmodel.dart';
import 'features/mahasiswa/viewmodels/log_mingguan_viewmodel.dart';
import 'features/mahasiswa/viewmodels/log_harian_viewmodel.dart';
import 'features/mahasiswa/viewmodels/ajuan_bimbingan_viewmodel.dart';

// Dosen Viewmodels
import 'features/dosen/viewmodels/ajuan_viewmodel.dart';
import 'features/dosen/viewmodels/bimbingan_viewmodel.dart';
import 'features/dosen/viewmodels/dosen_profil_viewmodel.dart';
import 'features/dosen/viewmodels/ajuan_riwayat_viewmodel.dart';
import 'features/dosen/viewmodels/bimbingan_riwayat_viewmodel.dart';
import 'features/dosen/viewmodels/dosen_mahasiswa_list_viewmodel.dart';
import 'features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';

// Admin Viewmodels
import 'features/admin/viewmodels/admin_viewmodel.dart';
import 'features/admin/viewmodels/admin_profile_viewmodel.dart';
import 'features/admin/viewmodels/admin_dashboard_viewmodel.dart';
import 'features/admin/viewmodels/admin_user_management_viewmodel.dart';
import 'features/admin/viewmodels/mapping/admin_dosen_list_vm.dart';
import 'features/admin/viewmodels/mapping/detail_mapping_vm.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. GLOBAL CORE
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),

        // 2. MAHASISWA VIEWMODELS
        ChangeNotifierProvider(create: (_) => MahasiswaViewModel()),
        ChangeNotifierProvider(create: (_) => MahasiswaLogMingguanViewModel()),
        ChangeNotifierProvider(create: (_) => MahasiswaLogHarianViewModel()),
        ChangeNotifierProvider(create: (_) => MahasiswaAjuanBimbinganViewModel()),

        // 3. DOSEN VIEWMODELS
        ChangeNotifierProvider(create: (_) => DosenProfilViewModel()),
        ChangeNotifierProvider(create: (_) => DosenMahasiswaListViewModel()),
        ChangeNotifierProvider(create: (_) => DosenLogbookHarianViewModel()),
        ChangeNotifierProvider(create: (_) => DosenAjuanViewModel()),
        ChangeNotifierProvider(create: (_) => DosenRiwayatAjuanViewModel()),
        ChangeNotifierProvider(create: (_) => DosenBimbinganViewModel()),
        ChangeNotifierProvider(create: (_) => DosenRiwayatBimbinganViewModel()),

        // 4. ADMIN VIEWMODELS
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
          // Mahasiswa Routes
          '/mahasiswa_detail_ajuan': (context) => const MahasiswaDetailAjuanScreen(),
          '/mahasiswa_detail_log_mingguan': (context) => const DetailLogMingguanScreen(),
          '/mahasiswa_detail_log_harian': (context) => const MahasiswaDetailLogHarianScreen(),
          '/mahasiswa_update_log_mingguan': (context) => const UpdateLogMingguanScreen(),

          // Dosen Routes
          // --- AJUAN BIMBINGAN ---
          '/detail_ajuan_validasi': (context) => const DosenAjuanDetail(),
          '/detail_ajuan_riwayat': (context) => const DosenAjuanRiwayatDetail(),

          // --- LOG BIMBINGAN ---
          '/detail_log_validasi': (context) => const DosenLogbookDetail(), 
          '/detail_log_riwayat': (context) => const DosenRiwayatBimbinganDetail(),

          // --- LOGBOOK HARIAN ---
          '/dosen_detail_log_harian': (context) => const LogbookHarianDetail(),
        },
      ),
    );
  }
}