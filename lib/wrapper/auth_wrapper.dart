// File: lib/core/wrappers/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/onboarding_screen.dart';
import '../../features/auth/views/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // Cek apakah user pernah selesai onboarding (hanya sekali)
  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  @override
Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Sedang loading Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // USER SUDAH LOGIN → langsung ke LoginPage (otomatis redirect ke dashboard)
        if (snapshot.hasData) {
          return const LoginPage();
        }

        // USER BELUM LOGIN → cek apakah sudah pernah lihat onboarding
        return FutureBuilder<bool>(
          future: _hasSeenOnboarding(),
          builder: (context, onboardSnapshot) {
            if (onboardSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            final hasSeenOnboarding = onboardSnapshot.data ?? false;

            return hasSeenOnboarding
                ? const LoginPage()
                : const OnboardingScreen();
          },
        );
      },
    );
  }
}