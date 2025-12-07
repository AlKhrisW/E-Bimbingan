import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebimbingan/main.dart' as app;

import '../common/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String kDosenEmail = "miftah@gmail.com";
  const String kDosenPassword = "password123";

  group("E2E Dosen Login", () {
    setUp(() async {
      // pastikan user logout dulu
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    });

    /// --- NAVIGASI ONBOARDING ---
    Future<void> navigateToLoginPage(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final headerLogin = find.text("Selamat Datang");
      final skipButton = find.text("SKIP");
      final masukButton = find.text("Masuk");
      final nextButton = find.byIcon(Icons.arrow_forward_ios);

      // Jika sudah di LoginPage langsung keluar
      if (tester.any(headerLogin)) return;

      // Loop maksimal 3 halaman onboarding
      for (var i = 0; i < 3; i++) {
        await tester.pumpAndSettle();

        if (tester.any(headerLogin)) {
          // Sudah masuk login
          return;
        }

        // Jika tombol SKIP ada → langsung ke LoginPage
        if (tester.any(skipButton)) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
          return;
        }

        // Jika halaman terakhir ada tombol Masuk → tap
        if (tester.any(masukButton)) {
          await tester.tap(masukButton);
          await tester.pumpAndSettle();
          return;
        }

        // Jika ada tombol NEXT → tap page berikutnya
        if (tester.any(nextButton)) {
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
        }
      }

      // Setelah loop selesai, pastikan benar-benar di login
      expect(
        headerLogin,
        findsOneWidget,
        reason: "Gagal masuk LoginPage setelah onboarding!",
      );
    }

    /// --- TEST UTAMA ---
    testWidgets(
      "D1. Login Berhasil Sebagai Dosen & Verifikasi Dashboard",
      (tester) async {
        // 1. Navigasi ke halaman login
        await navigateToLoginPage(tester);

        // 2. Login sebagai dosen
        await login(tester, kDosenEmail, kDosenPassword);

        // Pastikan tidak lagi di halaman login
        expect(find.text("Selamat Datang"), findsNothing);

        // 3. Verifikasi dashboard dosen
        await verifyDosenDashboard(tester);

        // 4. Logout via profil
        await logoutViaProfile(tester);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
