// integration_test/mahasiswa/ajuan_bimbingan_mahasiswa_negative_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Untuk signOut sebelum setiap test
import 'package:ebimbingan/main.dart' as app;

import '../common/test_helpers.dart';
import '../common/ajuan_bimbingan_mahasiswa_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String emailMahasiswa = 'e2etest@gmail.com';
  const String passwordMahasiswa = 'password';

  group('E2E Test - Ajuan Bimbingan Mahasiswa (Negative Cases)', () {
    // Sign out sebelum SETIAP test untuk memastikan state bersih
    setUp(() async {
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        // ignored
      }
    });

    Future<void> setupAndNavigateToForm(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await closeOnboarding(tester);

      await login(tester, emailMahasiswa, passwordMahasiswa);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      await verifyMahasiswaDashboard(tester);

      await AjuanBimbinganMahasiswaHelpers.bukaHalamanRiwayatAjuan(tester);

      expect(AjuanBimbinganMahasiswaHelpers.fabAdd, findsOneWidget);
      await tester.tap(AjuanBimbinganMahasiswaHelpers.fabAdd.first);
      await tester.pumpAndSettle(const Duration(seconds: 6));

      expect(find.text('Ajuan Bimbingan Baru'), findsOneWidget);
    }

    testWidgets('N1. Submit form kosong - error topik & metode wajib diisi', (
      tester,
    ) async {
      await setupAndNavigateToForm(tester);

      await tester.tap(AjuanBimbinganMahasiswaHelpers.buttonKirim);
      await tester.pumpAndSettle();

      expect(find.text('Topik wajib diisi.'), findsOneWidget);
      expect(find.text('Metode wajib diisi.'), findsOneWidget);
      expect(AjuanBimbinganMahasiswaHelpers.successMessage, findsNothing);

      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.chevron_left),
      );
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('N2. Topik kosong (metode diisi)', (tester) async {
      await setupAndNavigateToForm(tester);

      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldMetode,
        'Tatap Muka',
      );
      await tester.pumpAndSettle();

      await tester.tap(AjuanBimbinganMahasiswaHelpers.buttonKirim);
      await tester.pumpAndSettle();

      expect(find.text('Topik wajib diisi.'), findsOneWidget);
      expect(find.text('Metode wajib diisi.'), findsNothing);

      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.chevron_left),
      );
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('N3. Metode kosong (topik diisi)', (tester) async {
      await setupAndNavigateToForm(tester);

      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldTopik,
        'Konsultasi Bab 3',
      );
      await tester.pumpAndSettle();

      await tester.tap(AjuanBimbinganMahasiswaHelpers.buttonKirim);
      await tester.pumpAndSettle();

      expect(find.text('Metode wajib diisi.'), findsOneWidget);
      expect(find.text('Topik wajib diisi.'), findsNothing);

      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.chevron_left),
      );
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('N4. Topik terlalu pendek (< 5 karakter)', (tester) async {
      await setupAndNavigateToForm(tester);

      await tester.enterText(AjuanBimbinganMahasiswaHelpers.fieldTopik, 'ABCD');
      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldMetode,
        'Tatap Muka',
      );
      await tester.pumpAndSettle();

      await tester.tap(AjuanBimbinganMahasiswaHelpers.buttonKirim);
      await tester.pumpAndSettle();

      expect(find.text('Topik minimal 5 karakter.'), findsOneWidget);

      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.chevron_left),
      );
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('N5. Topik terlalu panjang (> 255 karakter)', (tester) async {
      await setupAndNavigateToForm(tester);

      final longTopik = 'A' * 300;
      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldTopik,
        longTopik,
      );
      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldMetode,
        'Tatap Muka',
      );
      await tester.pumpAndSettle();

      await tester.tap(AjuanBimbinganMahasiswaHelpers.buttonKirim);
      await tester.pumpAndSettle();

      expect(find.text('Topik maksimal 255 karakter.'), findsOneWidget);

      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.chevron_left),
      );
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('N6. Topik mengandung karakter terlarang', (tester) async {
      await setupAndNavigateToForm(tester);

      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldTopik,
        'Konsultasi #Bab1 @Dosen!!!',
      );
      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldMetode,
        'Tatap Muka',
      );
      await tester.pumpAndSettle();

      await tester.tap(AjuanBimbinganMahasiswaHelpers.buttonKirim);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Topik mengandung karakter tidak diizinkan'),
        findsOneWidget,
      );

      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.chevron_left),
      );
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('N7. Metode terlalu panjang (> 100 karakter)', (tester) async {
      await setupAndNavigateToForm(tester);

      final longMetode = 'Metode bimbingan sangat panjang sekali ' * 5;
      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldTopik,
        'Topik Valid',
      );
      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldMetode,
        longMetode,
      );
      await tester.pumpAndSettle();

      await tester.tap(AjuanBimbinganMahasiswaHelpers.buttonKirim);
      await tester.pumpAndSettle();

      expect(find.text('Metode maksimal 100 karakter.'), findsOneWidget);

      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.chevron_left),
      );
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('N8. Cancel form di tengah pengisian', (tester) async {
      await setupAndNavigateToForm(tester);

      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldTopik,
        'Ini akan dicancel',
      );
      await tester.enterText(
        AjuanBimbinganMahasiswaHelpers.fieldMetode,
        'Metode juga',
      );
      await tester.pumpAndSettle();

      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.chevron_left),
      );
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Riwayat Ajuan'), findsOneWidget);
      expect(AjuanBimbinganMahasiswaHelpers.successMessage, findsNothing);
    });
  });
}
