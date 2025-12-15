// lib/features/auth/views/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'onboarding_screen.dart';
import 'login_page.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../data/models/user_model.dart';

import '../../admin/views/admin_main_screen.dart';
import '../../mahasiswa/views/mahasiswa_main_screen.dart';
import '../../dosen/views/dosen_main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // State untuk mengontrol transparansi (opacity) logo
  double _logoOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Mulai alur aplikasi
    _startAppFlow();
  }

  // --- Alur Start Aplikasi ---
  void _startAppFlow() async {
    // 1. Animasi Logo (Fade In)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _logoOpacity = 1.0;
      });
    });

    // 2. Tahan splash screen sebentar (misal 2 detik) agar tidak berkedip terlalu cepat
    await Future.delayed(const Duration(seconds: 2));

    // 3. Cek Shared Preferences: Apakah ini pertama kali install?
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('is_first_time') ?? true;

    if (!mounted) return;

    if (isFirstTime) {
      // Pengguna Baru -> Ke Onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      // Bukan Pengguna Baru -> Cek Apakah Login?
      _checkAutoLogin();
    }
  }

  void _checkAutoLogin() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    // Panggil fungsi cek status yang ada di AuthViewModel
    final UserModel? user = await authViewModel.checkLoginStatus();

    if (!mounted) return;

    if (user != null) {
      // Jika Login Berhasil -> Arahkan ke Dashboard sesuai Role
      _navigateToDashboard(user);
    } else {
      // Jika Token Kadaluarsa/Belum Login -> Ke Login Page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _navigateToDashboard(UserModel user) {
    Widget destination;

    switch (user.role) {
      case 'admin':
        destination = AdminMainScreen(user: user);
        break;
      case 'dosen':
        destination = DosenMain(user: user);
        break;
      case 'mahasiswa':
        destination = MahasiswaMainScreen(user: user);
        break;
      default:
        // Fallback jika role error atau tidak dikenali
        destination = const LoginPage();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => destination),
    );
  }
  // ----------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _logoOpacity,
          duration: const Duration(seconds: 2), // Durasi transisi fade-in
          curve: Curves.easeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              // --- LOGO E-BIMBINGAN ---
              Image(
                image: AssetImage('assets/images/login/logo_ebimbingan.png'),
                height: 180,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}