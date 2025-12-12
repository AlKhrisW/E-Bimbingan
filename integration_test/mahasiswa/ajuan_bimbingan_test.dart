// File: integration_test/mahasiswa/ajuan_bimbingan_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebimbingan/main.dart' as app;

// Import helpers
import '../common/test_helpers.dart' as helpers;
import '../common/ajuan_helpers.dart'; // Berisi semua helper Ajuan, termasuk logoutViaProfileMahasiswa

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String mahasiswaEmail = 'e2e@gmail.com';
  const String mahasiswaPassword = 'password';

  group('E2E Mahasiswa - Ajuan Bimbingan Flow', () {
    // Setup dilakukan sekali untuk semua test
    setUpAll(() async {
      print('🚀 [SETUP] Memulai test suite...');
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 1));
        print('✅ [SETUP] Logout berhasil');
      } catch (e) {
        print('⚠️ [SETUP] Error saat logout: $e (ignored)');
      }
    });

    // Setup helper untuk login dan navigasi ke Riwayat Ajuan di setiap test
    Future<void> setupTestAndNavigate(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await helpers.closeOnboarding(tester);
      await helpers.login(tester, mahasiswaEmail, mahasiswaPassword);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✅ Login berhasil');
      await navigateToAjuanHistory(tester);
      print('✅ Berhasil navigasi ke Riwayat Ajuan');
    }

    // Setup helper hanya untuk login (dipakai Test D)
    Future<void> setupTestOnlyLogin(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await helpers.closeOnboarding(tester);
      await helpers.login(tester, mahasiswaEmail, mahasiswaPassword);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✅ Login berhasil');
    }

    // =============================================================
    // TEST A: LOGIN & NAVIGASI
    // =============================================================
    testWidgets(
      'A. Login Mahasiswa dan Navigasi ke Ajuan',
      (tester) async {
        print('\n📋 [TEST A] Login Mahasiswa dan Navigasi ke Ajuan');
        print('=' * 60);

        // Menggunakan helper yang sudah mencakup semua langkah A
        await setupTestAndNavigate(tester);

        print('=' * 60);
        print('✅ [TEST A] SELESAI\n');
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    // =============================================================
    // TEST B: SUBMIT AJUAN POSITIF
    // =============================================================
    testWidgets(
      'B. Ajuan Positif: Submit form dengan data valid',
      (tester) async {
        print('\n📋 [TEST B] Ajuan Positif dengan Data Valid');
        print('=' * 60);

        await setupTestAndNavigate(
          tester,
        ); // Mulai dari Dashboard -> Ajuan History

        // Navigate to form
        await navigateToTambahAjuan(tester);

        // Fill form
        final String topik = 'E2E Test POSITIF: Konsultasi Bab 3 Metodologi';
        final String metode = 'Tatap Muka di Ruang Dosen';
        await fillAjuanForm(tester, topik: topik, metode: metode);

        // Submit
        await submitAjuan(tester);

        // Verify success (Menggunakan helper yang sudah diperbaiki)
        await verifySubmissionSuccess(tester);

        // Verify in list
        await verifyNewAjuanInList(tester, topik);

        print('=' * 60);
        print('✅ [TEST B] SELESAI\n');
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    // =============================================================
    // TEST C: VALIDASI FORM NEGATIF
    // =============================================================
    testWidgets(
      'C. Ajuan Negatif: Submit form tanpa data (Validasi UI)',
      (tester) async {
        print('\n📋 [TEST C] Ajuan Negatif - Validasi Form');
        print('=' * 60);

        await setupTestAndNavigate(
          tester,
        ); // Mulai dari Dashboard -> Ajuan History

        // Navigate to form
        await navigateToTambahAjuan(tester);

        // Submit without filling
        await submitAjuan(tester);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Menggunakan Finder yang lebih umum karena validasi ada di VM/CustomTextArea
        expect(find.textContaining('wajib diisi'), findsWidgets);
        print('✅ Validasi form berfungsi dengan benar');

        // Back to list - gunakan helper navigation
        await navigateBack(tester);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        print('=' * 60);
        print('✅ [TEST C] SELESAI\n');
      },
      timeout: const Timeout(Duration(seconds: 90)),
    );

    // =============================================================
    // TEST D: LOGOUT
    // =============================================================
    testWidgets('D. Logout Mahasiswa', (tester) async {
      print('\n📋 [TEST D] Logout Mahasiswa');
      print('=' * 60);

      await setupTestOnlyLogin(tester); // Mulai dari Dashboard

      // Lakukan logout
      await logoutViaProfileMahasiswa(tester);

      print('=' * 60);
      print('✅ [TEST D] SELESAI\n');
    }, timeout: const Timeout(Duration(seconds: 90)));
  });
}
