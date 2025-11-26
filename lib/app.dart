// lib/app.dart

import 'package:ebimbingan/data/services/firebase_auth_service.dart';
import 'package:ebimbingan/data/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/themes/app_theme.dart';
import 'core/utils/navigation/app_navigator.dart';
import 'features/auth/views/splash_screen.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/admin/viewmodels/admin_viewmodel.dart';
import 'features/admin/viewmodels/admin_profile_viewmodel.dart';
import 'features/admin/viewmodels/admin_dashboard_viewmodel.dart';
import 'features/admin/viewmodels/admin_user_management_viewmodel.dart';
import 'features/dosen/viewmodels/dosen_viewmodel.dart';
import 'features/mahasiswa/viewmodels/mahasiswa_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global / Tingkat Tertinggi
        ChangeNotifierProvider(create: (_) => AuthViewModel()),

        // Provider Umum (dipakai di banyak role)
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => DosenViewModel(authService: FirebaseAuthService(),userService: UserService())),
        ChangeNotifierProvider(create: (_) => MahasiswaViewModel(authService: FirebaseAuthService(),userService: UserService())),

        // Provider Khusus Admin
        ChangeNotifierProvider(create: (_) => AdminProfileViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AdminUserManagementViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'E-Bimbingan App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false, // optional, tapi biasanya ditambahkan
        home: const SplashScreen(),
      ),
    );
  }
}