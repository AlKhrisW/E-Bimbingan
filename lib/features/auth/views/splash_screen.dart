// lib/features/auth/views/splash_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart'; 

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
    // 1. Mulai Timer dan Animasi
    _startAnimationAndTimer();
  }

  void _startAnimationAndTimer() {
    // Memberikan waktu agar widget selesai di-render, lalu mulai animasi (fade in)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _logoOpacity = 1.0; 
      });
    });

    // Panggil timer untuk navigasi setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      // Navigasi ke OnboardingScreen (Halaman Pertama)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

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
              // --- LOGO E-BIMBINGAN (PATH FINAL) ---
              Image(
                // Menggunakan path yang disepakati untuk PNG
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