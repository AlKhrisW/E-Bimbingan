// integration_test/mahasiswa/mahasiswa_ajuan_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebimbingan/main.dart' as app;

// Import Helper General
import '../common/test_helpers.dart';
// Import Helper Mahasiswa Ajuan Spesifik
import '../common/mahasiswa_profile_helpers.dart';
import '../common/mahasiswa_ajuan_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const mahasiswaEmail = 'e2e@gmail.com';
  const mahasiswaPassword = 'password';

  // --- Data untuk Test Case ---
  const testTopik = 'Revisi Bab 2 Proposal';
  const testMetode = 'Zoom Meeting';
  // -----------------------------

  group('E2E Mahasiswa Ajuan Bimbingan', () {
    setUp(() async {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    });

    // =============================================================
    // ==================== POSITIVE TEST ==========================
    // =============================================================

    testWidgets(
      'Mahasiswa dapat submit ajuan bimbingan dengan data lengkap',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // 1. Login sebagai MAHASISWA
        await closeOnboarding(tester);
        await login(tester, mahasiswaEmail, mahasiswaPassword);
        await verifyMahasiswaDashboard(tester);
        print('✅ Login Mahasiswa Berhasil.');

        // 2. Navigasi ke Tab "Ajuan"
        await navigateToAjuanTab(tester);

        // 3. Navigasi ke Form Ajuan Bimbingan (FAB)
        await navigateToCreateAjuan(tester);

        // 4. Isi Form dengan Data Lengkap
        await fillAjuanForm(
          tester: tester,
          topik: testTopik,
          metode: testMetode,
          selectWaktu: true,
          selectTanggal: true,
        );

        // 5. Submit Ajuan
        await submitAjuan(tester);

        // 6. Verifikasi Success Screen
        await verifySuccessScreen(tester);
        print('✅ Ajuan bimbingan berhasil diajukan!');

        // 7. Tap Kembali dari Success Screen
        await tapKembaliFromSuccess(tester);
        print('✅ Kembali ke Riwayat Ajuan.');

        // 8. Logout (✅ helper KHUSUS mahasiswa)
        await logoutMahasiswaViaProfile(tester);
        print('✅ Test Selesai. Logout berhasil.');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    // =============================================================
    // ==================== NEGATIVE TESTS =========================
    // =============================================================

    testWidgets(
      'NEGATIVE: Submit gagal jika Topik kosong',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await closeOnboarding(tester);
        await login(tester, mahasiswaEmail, mahasiswaPassword);
        await verifyMahasiswaDashboard(tester);

        await navigateToAjuanTab(tester);
        await navigateToCreateAjuan(tester);

        await fillAjuanForm(
          tester: tester,
          topik: '',
          metode: testMetode,
          selectWaktu: true,
          selectTanggal: true,
        );

        await submitAjuan(tester);

        await verifyAjuanValidationError(tester, 'Topik bimbingan harus diisi');

        await verifyStillOnAjuanPage(tester);

        await cleanupAjuanTest(tester);
        await logoutMahasiswaViaProfile(tester);
        print('✅ Negative Test [Topik Kosong] Selesai.');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    testWidgets(
      'NEGATIVE: Submit gagal jika Metode kosong',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await closeOnboarding(tester);
        await login(tester, mahasiswaEmail, mahasiswaPassword);
        await verifyMahasiswaDashboard(tester);

        await navigateToAjuanTab(tester);
        await navigateToCreateAjuan(tester);

        await fillAjuanForm(
          tester: tester,
          topik: testTopik,
          metode: '',
          selectWaktu: true,
          selectTanggal: true,
        );

        await submitAjuan(tester);

        await verifyAjuanValidationError(
          tester,
          'Metode bimbingan harus diisi',
        );

        await verifyStillOnAjuanPage(tester);

        await cleanupAjuanTest(tester);
        await logoutMahasiswaViaProfile(tester);
        print('✅ Negative Test [Metode Kosong] Selesai.');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    testWidgets(
      'NEGATIVE: Submit gagal jika Waktu belum dipilih',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await closeOnboarding(tester);
        await login(tester, mahasiswaEmail, mahasiswaPassword);
        await verifyMahasiswaDashboard(tester);

        await navigateToAjuanTab(tester);
        await navigateToCreateAjuan(tester);

        await fillAjuanForm(
          tester: tester,
          topik: testTopik,
          metode: testMetode,
          selectWaktu: false,
          selectTanggal: true,
        );

        await submitAjuan(tester);

        await verifyAjuanValidationError(tester, 'Waktu harus diisi');
        await verifyStillOnAjuanPage(tester);

        await cleanupAjuanTest(tester);
        await logoutMahasiswaViaProfile(tester);
        print('✅ Negative Test [Waktu Kosong] Selesai.');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    testWidgets(
      'NEGATIVE: Submit gagal jika Tanggal belum dipilih',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await closeOnboarding(tester);
        await login(tester, mahasiswaEmail, mahasiswaPassword);
        await verifyMahasiswaDashboard(tester);

        await navigateToAjuanTab(tester);
        await navigateToCreateAjuan(tester);

        await fillAjuanForm(
          tester: tester,
          topik: testTopik,
          metode: testMetode,
          selectWaktu: true,
          selectTanggal: false,
        );

        await submitAjuan(tester);

        await verifyAjuanValidationError(tester, 'Tanggal harus diisi');
        await verifyStillOnAjuanPage(tester);

        await cleanupAjuanTest(tester);
        await logoutMahasiswaViaProfile(tester);
        print('✅ Negative Test [Tanggal Kosong] Selesai.');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    testWidgets(
      'NEGATIVE: Submit gagal jika semua field kosong',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await closeOnboarding(tester);
        await login(tester, mahasiswaEmail, mahasiswaPassword);
        await verifyMahasiswaDashboard(tester);

        await navigateToAjuanTab(tester);
        await navigateToCreateAjuan(tester);

        await submitAjuan(tester);

        await verifyAjuanValidationError(tester, 'harus diisi');
        await verifyStillOnAjuanPage(tester);

        await cleanupAjuanTest(tester);
        await logoutMahasiswaViaProfile(tester);
        print('✅ Negative Test [Semua Field Kosong] Selesai.');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
