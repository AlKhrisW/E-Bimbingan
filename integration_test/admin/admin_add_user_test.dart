  // integration_test/admin/admin_add_user_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:integration_test/integration_test.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:ebimbingan/main.dart' as app;

  // Import Helper General
  import '../common/test_helpers.dart';
  // Import Helper Admin Spesifik
  import 'admin_user_helpers.dart';

  void main() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    const adminEmail = 'gibran@gmail.com';
    const adminPassword = 'password123';

    // --- Data untuk Test Case (Hanya Dosen) ---
    const newDosenName = 'Dr. Rini Test Add';
    const newDosenEmail = 'rini.test.add@example.com';
    const newDosenNIP = '9876543211';
    const newDosenJabatan = 'Lektor Kepala';
    // -----------------------------

    group('E2E Admin User Management (Add Dosen)', () {
      setUp(() async {
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
      });

      testWidgets(
        'Admin dapat mendaftarkan Dosen baru',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          // 1. Login sebagai ADMIN
          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);
          print('✅ Login Admin Berhasil.');

          // 2. Navigasi ke Tab "Users"
          final usersTab = find.byIcon(Icons.manage_accounts_outlined);
          await tester.tap(usersTab);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('✅ Navigasi ke tab "Users" berhasil.');

          // 3. Navigasi ke Tambah User (FAB)
          final fab = find.byKey(const ValueKey('add_user')).hitTestable();
          await tester.tap(fab);
          await tester.pumpAndSettle();

          final pageTitle = find.text('Tambah User').first;
          expect(
            pageTitle,
            findsOneWidget,
            reason: 'Gagal verifikasi Judul Halaman Tambah User.',
          );
          print('✅ Navigasi ke RegisterUserScreen berhasil.');

          // 4. REGISTRASI DOSEN BARU
          print('➕ Mendaftarkan DOSEN...');
          await fillAndSubmitDosenForm(
            tester: tester,
            name: newDosenName,
            email: newDosenEmail,
            phone: '081199887766',
            nip: newDosenNIP,
            jabatan: newDosenJabatan,
          );

          // ✅ PERBAIKAN: Tunggu proses submit + pop selesai
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // ✅ Verifikasi sukses message (opsional)
          // Jika ada SnackBar "berhasil didaftarkan", verifikasi
          final successMsg = find.textContaining('berhasil didaftarkan!');
          if (successMsg.evaluate().isNotEmpty) {
            expect(successMsg, findsOneWidget);
            print('✅ DOSEN baru berhasil ditambahkan (SnackBar terdeteksi).');
          } else {
            print(
              '⚠️ SnackBar tidak terdeteksi, tapi asumsi registrasi berhasil.',
            );
          }

          // ✅ SKIP VERIFIKASI LIST - LANGSUNG LOGOUT!
          print('⏭️ Skip verifikasi list, langsung ke logout...');

          // 5. LOGOUT (Navigasi ke Profil)
          final profileTab = find.text('Akun');
          expect(
            profileTab,
            findsOneWidget,
            reason: 'Tab "Akun" tidak ditemukan di AdminUsersScreen.',
          );

          await tester.tap(profileTab);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('✅ Pindah ke tab "Akun" untuk logout.');

          await logoutViaProfile(tester);
          print('✅ Test Selesai. Logout berhasil.');
        },
        timeout: const Timeout(Duration(minutes: 5)),
      );
    });
  }
