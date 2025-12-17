import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebimbingan/main.dart' as app;
import '../common/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Login - Admin', () {
    setUp(() async {
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print('Setup logout error (ignored): $e');
      }
    });

    testWidgets(
      'Login Admin → Verify Dashboard → Logout',
      (tester) async {
        app.main();

        await tester.pumpAndSettle(const Duration(seconds: 4));

        final skipButton = find.text('SKIP');

        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else {
          final masukButton = find.text('Masuk').first;
          await tester.tap(masukButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        expect(find.text('Selamat Datang'), findsOneWidget);
        expect(find.text('Masuk ke akun Anda'), findsOneWidget);

        await login(tester, 'gibran@gmail.com', 'password123');

        await verifyAdminDashboard(tester);

        await logoutViaProfile(tester);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}