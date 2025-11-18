// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/views/splash_screen.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/admin/viewmodels/admin_viewmodel.dart'; 

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        // FIX: Tambahkan AdminViewModel secara GLOBAL di sini
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: MaterialApp(
        title: 'E-Bimbingan App',
        theme: AppTheme.lightTheme, 
        home: const SplashScreen(),
      ),
    );
  }
}