import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebimbingan/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Login - Negative Cases', () {
    setUp(() async {
      // Pastikan user logout sebelum setiap tes
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        // Abaikan error jika user sudah logout
      }
    });

    // Helper untuk skip onboarding dan ke login page
    Future<void> navigateToLoginPage(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final skipButton = find.text('SKIP');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else {
        // Asumsi Masuk button ada di akhir onboarding jika tidak ada skip
        final masukButton = find.text('Masuk').first;
        await tester.tap(masukButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }

    testWidgets(
      'Login gagal - Email kosong',
      (tester) async {
        await navigateToLoginPage(tester);

        // Pastikan di halaman login
        expect(find.text('Selamat Datang'), findsOneWidget);

        // Input password saja (email kosong)
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pumpAndSettle();

        // Tap tombol Masuk
        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle(); // Menggunakan pumpAndSettle() yang efisien

        // Verifikasi error message muncul
        expect(find.text('Email wajib diisi'), findsOneWidget);
        
        // Pastikan tetap di halaman login
        expect(find.text('Selamat Datang'), findsOneWidget);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'Login gagal - Password kosong',
      (tester) async {
        await navigateToLoginPage(tester);

        // Input email saja (password kosong)
        await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
        await tester.pumpAndSettle();

        // Tap tombol Masuk
        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle(); // Menggunakan pumpAndSettle() yang efisien

        // Verifikasi error message muncul
        expect(find.text('Minimal 6 karakter'), findsOneWidget);
        
        // Pastikan tetap di halaman login
        expect(find.text('Selamat Datang'), findsOneWidget);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'Login gagal - Password kurang dari 6 karakter',
      (tester) async {
        await navigateToLoginPage(tester);

        // Input email dan password pendek
        await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
        await tester.enterText(find.byType(TextFormField).at(1), '12345');
        await tester.pumpAndSettle();

        // Tap tombol Masuk
        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle(); // Menggunakan pumpAndSettle() yang efisien

        // Verifikasi error message muncul
        expect(find.text('Minimal 6 karakter'), findsOneWidget);
        
        // Pastikan tetap di halaman login
        expect(find.text('Selamat Datang'), findsOneWidget);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'Login gagal - Email tidak terdaftar',
      (tester) async {
        await navigateToLoginPage(tester);

        // Input email yang tidak terdaftar
        await tester.enterText(find.byType(TextFormField).at(0), 'tidakterdaftar@gmail.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pumpAndSettle();

        // Tap tombol Masuk
        await tester.tap(find.text('Masuk'));
        // Menggunakan pumpAndSettle() tanpa durasi spesifik untuk menunggu respons Firebase
        await tester.pumpAndSettle(); 

        // Verifikasi LoginAlert dengan error muncul (Menggunakan teks, bukan ikon yang bermasalah)
        expect(find.text('Email atau password salah.'), findsOneWidget);
        
        // Pastikan tetap di halaman login
        expect(find.text('Selamat Datang'), findsOneWidget);

        // Opsional: Tunggu alert hilang (3 detik + buffer)
        await tester.pumpAndSettle(const Duration(seconds: 4));
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'Login gagal - Password salah',
      (tester) async {
        await navigateToLoginPage(tester);

        // Input email benar tapi password salah
        await tester.enterText(find.byType(TextFormField).at(0), 'gibran@gmail.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'passwordsalah123');
        await tester.pumpAndSettle();

        // Tap tombol Masuk
        await tester.tap(find.text('Masuk'));
        // Menggunakan pumpAndSettle() tanpa durasi spesifik untuk menunggu respons Firebase
        await tester.pumpAndSettle();

        // Verifikasi LoginAlert dengan error muncul (Menggunakan teks, bukan ikon yang bermasalah)
        expect(find.text('Email atau password salah.'), findsOneWidget);
        
        // Pastikan tetap di halaman login
        expect(find.text('Selamat Datang'), findsOneWidget);
        
        // Opsional: Tunggu alert hilang (3 detik + buffer)
        await tester.pumpAndSettle(const Duration(seconds: 4));
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'Login gagal - Email dan Password kosong',
      (tester) async {
        await navigateToLoginPage(tester);

        // Tidak input apapun, langsung tap Masuk
        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle(); // Menggunakan pumpAndSettle() yang efisien

        // Verifikasi error message muncul (minimal email wajib diisi)
        expect(find.text('Email wajib diisi'), findsOneWidget);
        
        // Pastikan tetap di halaman login
        expect(find.text('Selamat Datang'), findsOneWidget);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}