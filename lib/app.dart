// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/navigation/app_navigator.dart';
import 'features/auth/views/splash_screen.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftarkan Provider utama (Auth)
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        // Provider lain akan ditambahkan di fitur masing-masing
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'E-Bimbingan App',
        theme: AppTheme.lightTheme, // Menggunakan tema yang sudah didefinisikan
        home: const SplashScreen(),
        // TODO: Gunakan named routes dari app_routes.dart jika diperlukan
      ),
    );
  }
}