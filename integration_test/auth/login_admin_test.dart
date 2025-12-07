
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
        // Start aplikasi
        app.main();
        
        // Tunggu splash screen selesai (3 detik + buffer)
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // SKIP ONBOARDING: Tap tombol "SKIP"
        final skipButton = find.text('SKIP');
        
        if (skipButton.evaluate().isNotEmpty) {
          print('⏭️ Melewati onboarding...');
          await tester.tap(skipButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else {
          // Jika tidak ada tombol SKIP, berarti sudah di halaman terakhir
          // Tap tombol "Masuk" di onboarding
          final masukButton = find.text('Masuk').first;
          await tester.tap(masukButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Sekarang di halaman login
        print('✅ Berhasil ke halaman login');
        expect(find.text('Selamat Datang'), findsOneWidget);
        expect(find.text('Masuk ke akun Anda'), findsOneWidget);

        // Login sebagai Admin
        print('🔐 Melakukan login admin...');
        await login(tester, 'gibran@gmail.com', 'password123');
        
        // Verify Admin Dashboard
        print('📊 Verifikasi admin dashboard...');
        await verifyAdminDashboard(tester);
        
        // Logout
        print('🚪 Melakukan logout...');
        await logoutViaProfile(tester);
        
        print('✅ ADMIN: Login + Dashboard + Logout BERHASIL');
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}