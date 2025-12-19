// integration_test/mahasiswa/ajuan_bimbingan_mahasiswa_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ebimbingan/main.dart' as app;

import '../common/test_helpers.dart';
import '../common/ajuan_bimbingan_mahasiswa_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String emailMahasiswa = 'e2etest@gmail.com';
  const String passwordMahasiswa = 'password';

  const String topikTest = 'E2E Test - Konsultasi Bab 4 Metodologi';
  const String metodeTest = 'Tatap muka di ruang dosen';

  group('E2E Test - Ajuan Bimbingan Mahasiswa (Positive Case)', () {
    testWidgets(
      'Mahasiswa berhasil membuat ajuan bimbingan baru, melihatnya di riwayat, dan membuka detail',
      (WidgetTester tester) async {
        // 1. Launch aplikasi
        app.main();
        await tester.pumpAndSettle();

        // 2. Lewati onboarding jika ada
        await closeOnboarding(tester);

        // 3. Login sebagai mahasiswa test
        await login(tester, emailMahasiswa, passwordMahasiswa);

        // 4. Beri waktu ekstra untuk load data dashboard
        await tester.pumpAndSettle(const Duration(seconds: 8));

        // 5. Verifikasi dashboard mahasiswa
        await verifyMahasiswaDashboard(tester);

        // 6. Buka halaman Riwayat Ajuan
        await AjuanBimbinganMahasiswaHelpers.bukaHalamanRiwayatAjuan(tester);

        // 7. Buat ajuan bimbingan baru
        await AjuanBimbinganMahasiswaHelpers.buatAjuanBaru(
          tester: tester,
          topik: topikTest,
          metode: metodeTest,
        );

        // 8. Verifikasi ajuan baru muncul di riwayat
        await AjuanBimbinganMahasiswaHelpers.verifikasiAjuanMunculDiRiwayat(
          tester,
          topikTest,
        );

        // 9. Buka detail ajuan
        await AjuanBimbinganMahasiswaHelpers.bukaDetailAjuan(tester, topikTest);

        // 10. Verifikasi isi detail benar
        expect(find.text(topikTest), findsOneWidget);
        expect(find.text(metodeTest), findsOneWidget);
        expect(find.text('Menunggu Persetujuan'), findsOneWidget);
        expect(find.textContaining('Dosen Pembimbing'), findsOneWidget);

        // FINAL: Kembali dari detail dengan tap CustomBackButton (icon chevron_left di AppBar)
        final backButton = find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.chevron_left),
        );

        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Pastikan sudah kembali ke riwayat
        expect(find.text('Riwayat Ajuan'), findsOneWidget);

        // 11. Logout
        await logoutViaProfileMahasiswa(tester);
      },
    );
  });
}
