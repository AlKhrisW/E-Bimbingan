import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebimbingan/main.dart' as app;

import '../common/test_helpers.dart' as helpers;
import '../common/ajuan_helpers.dart';
import '../common/ajuan_negative_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String mahasiswaEmail = 'e2e@gmail.com';
  const String mahasiswaPassword = 'password';

  group('E2E Mahasiswa - Ajuan Bimbingan Negative Tests', () {
    setUpAll(() async {
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        // ignored
      }
    });

    Future<void> setupTest(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await helpers.closeOnboarding(tester);
      await helpers.login(tester, mahasiswaEmail, mahasiswaPassword);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await navigateToAjuanHistory(tester);
    }

    group('Group 1: Form Validation Tests', () {
      testWidgets(
        'C1. Submit form kosong - tidak isi apapun',
        (tester) async {
          await setupTest(tester);
          await testSubmitEmptyForm(tester);
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );

      testWidgets(
        'C2. Submit hanya dengan Topik (Metode kosong)',
        (tester) async {
          await setupTest(tester);
          await testSubmitOnlyTopik(tester);
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );

      testWidgets(
        'C3. Submit hanya dengan Metode (Topik kosong)',
        (tester) async {
          await setupTest(tester);
          await testSubmitOnlyMetode(tester);
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );
    });

    group('Group 2: Whitespace & Edge Cases', () {
      testWidgets(
        'C4. Submit Topik dengan whitespace saja',
        (tester) async {
          await setupTest(tester);
          await testSubmitTopikWhitespace(tester);
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );

      testWidgets(
        'C5. Submit Metode dengan whitespace saja',
        (tester) async {
          await setupTest(tester);
          await testSubmitMetodeWhitespace(tester);
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );

      testWidgets(
        'C6. Submit Topik terlalu pendek',
        (tester) async {
          await setupTest(tester);
          await testSubmitTopikTooShort(tester);
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );

      testWidgets(
        'C7. Submit Topik terlalu panjang',
        (tester) async {
          await setupTest(tester);
          await testSubmitTopikTooLong(tester);
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );
    });

    group('Group 3: Special Characters & Behavior', () {
      testWidgets(
        'C8. Submit dengan karakter special & emoji',
        (tester) async {
          await setupTest(tester);
          await testSubmitWithSpecialCharacters(tester);
        },
        timeout: const Timeout(Duration(minutes: 2)),
      );

      testWidgets(
        'C10. Cancel form di tengah pengisian',
        (tester) async {
          await setupTest(tester);
          await testCancelFormMidway(tester);
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );
    });
  });
}