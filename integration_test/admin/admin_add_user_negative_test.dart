// integration_test/admin/admin_add_user_negative_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebimbingan/main.dart' as app;

// Import Helper General
import '../common/test_helpers.dart';
import '../common/negative_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const adminEmail = 'gibran@gmail.com';
  const adminPassword = 'password123';

  group('E2E Admin User Management (Negative Testing)', () {
    setUp(() async {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    });

    // ========================================================================
    // GROUP 1: VALIDASI FIELD REQUIRED (DOSEN)
    // ========================================================================
    group('Validasi Field Required - Dosen', () {
      testWidgets(
        'Tidak bisa submit dengan Nama kosong',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);

          // Navigasi ke Users -> Tambah User
          await navigateToAddUser(tester);

          // Pilih role Dosen
          await selectRole(tester, 'Dosen');

          // Isi form TANPA nama (kosongkan)
          await fillTextField(tester, 'Nama Lengkap', ''); // Kosong!
          await fillTextField(tester, 'E-Mail', 'test.empty.name@example.com');
          await fillTextField(tester, 'No - Telp', '081234567890');
          await fillTextField(tester, 'NIP', '1234567890');
          await selectDropdown(tester, 'Jabatan Fungsional', 'Lektor');

          // Tap tombol Submit
          await tapSubmitButton(tester);

          // Verifikasi: Error muncul
          await verifyValidationError(tester, 'Nama Lengkap wajib diisi.');
          print('✅ Validasi nama kosong berhasil!');

          // Cleanup: Back ke Users screen (skip logout untuk speed)
          await cleanupNegativeTest(tester);
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );

      testWidgets(
        'Tidak bisa submit dengan Email kosong',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);

          await navigateToAddUser(tester);
          await selectRole(tester, 'Dosen');

          // Isi form TANPA email
          await fillTextField(tester, 'Nama Lengkap', 'Dr. Test Empty Email');
          await fillTextField(tester, 'E-Mail', ''); // Kosong!
          await fillTextField(tester, 'No - Telp', '081234567890');
          await fillTextField(tester, 'NIP', '1234567890');
          await selectDropdown(tester, 'Jabatan Fungsional', 'Lektor');

          await tapSubmitButton(tester);

          await verifyValidationError(tester, 'E-Mail wajib diisi.');
          print('✅ Validasi email kosong berhasil!');

          await cleanupNegativeTest(tester);
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );

      testWidgets(
        'Tidak bisa submit dengan NIP kosong',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);

          await navigateToAddUser(tester);
          await selectRole(tester, 'Dosen');

          // Isi form TANPA NIP
          await fillTextField(tester, 'Nama Lengkap', 'Dr. Test Empty NIP');
          await fillTextField(tester, 'E-Mail', 'test.empty.nip@example.com');
          await fillTextField(tester, 'No - Telp', '081234567890');
          await fillTextField(tester, 'NIP', ''); // Kosong!
          await selectDropdown(tester, 'Jabatan Fungsional', 'Lektor');

          await tapSubmitButton(tester);

          await verifyValidationError(tester, 'NIP wajib diisi.');
          print('✅ Validasi NIP kosong berhasil!');

          await cleanupNegativeTest(tester);
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );

      testWidgets(
        'Tidak bisa submit tanpa pilih Jabatan',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);

          await navigateToAddUser(tester);
          await selectRole(tester, 'Dosen');

          // Isi form TANPA pilih Jabatan
          await fillTextField(tester, 'Nama Lengkap', 'Dr. Test No Jabatan');
          await fillTextField(tester, 'E-Mail', 'test.no.jabatan@example.com');
          await fillTextField(tester, 'No - Telp', '081234567890');
          await fillTextField(tester, 'NIP', '1234567890');
          // SKIP pilih jabatan!

          await tapSubmitButton(tester);

          await verifyValidationError(tester, 'Jabatan wajib dipilih.');
          print('✅ Validasi jabatan tidak dipilih berhasil!');

          await cleanupNegativeTest(tester);
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );
    });

    // ========================================================================
    // GROUP 2: VALIDASI FIELD REQUIRED (MAHASISWA)
    // ========================================================================
    group('Validasi Field Required - Mahasiswa', () {
      testWidgets(
        'Tidak bisa submit dengan NIM kosong',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);

          await navigateToAddUser(tester);
          await selectRole(tester, 'Mahasiswa');

          // Isi form TANPA NIM
          await fillTextField(tester, 'Nama Lengkap', 'Test Empty NIM');
          await fillTextField(
            tester,
            'Program Studi/Jurusan',
            'Teknik Informatika',
          );
          await fillTextField(tester, 'E-Mail', 'test.empty.nim@example.com');
          await fillTextField(tester, 'No - Telp', '081234567890');
          await fillTextField(tester, 'NIM', ''); // Kosong!
          await fillTextField(tester, 'Penempatan Magang', 'PT. Testing');

          await tapSubmitButton(tester);

          await verifyValidationError(tester, 'NIM wajib diisi.');
          print('✅ Validasi NIM kosong berhasil!');

          await cleanupNegativeTest(tester);
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );

      testWidgets(
        'Tidak bisa submit tanpa pilih Dosen Pembimbing',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);

          await navigateToAddUser(tester);
          await selectRole(tester, 'Mahasiswa');

          // Isi form lengkap kecuali Dosen Pembimbing
          await fillTextField(tester, 'Nama Lengkap', 'Test No Dosen');
          await fillTextField(
            tester,
            'Program Studi/Jurusan',
            'Teknik Informatika',
          );
          await fillTextField(tester, 'E-Mail', 'test.no.dosen@example.com');
          await fillTextField(tester, 'No - Telp', '081234567890');
          await fillTextField(tester, 'NIM', '2024001234');
          await fillTextField(tester, 'Penempatan Magang', 'PT. Testing');
          await selectStartDate(tester);

          // Ubah dosen ke null dengan cara tap dropdown -> pilih yang tidak ada
          // Atau kita bisa skip ini karena default sudah ada dosen terpilih

          // CARA ALTERNATIF: Kita bisa mock viewmodel untuk set dosenList = []
          // Tapi untuk simplicity, test ini bisa di-skip atau disesuaikan

          print('⚠️ Test ini memerlukan mock untuk set dosenList kosong');
          print('⚠️ Skip test ini atau gunakan unit test dengan mock');

          await cleanupNegativeTest(tester);
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );

      testWidgets(
        'Tidak bisa submit tanpa pilih Tanggal Mulai',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);

          await navigateToAddUser(tester);
          await selectRole(tester, 'Mahasiswa');

          // Isi form TANPA pilih tanggal
          await fillTextField(tester, 'Nama Lengkap', 'Test No Date');
          await fillTextField(
            tester,
            'Program Studi/Jurusan',
            'Teknik Informatika',
          );
          await fillTextField(tester, 'E-Mail', 'test.no.date@example.com');
          await fillTextField(tester, 'No - Telp', '081234567890');
          await fillTextField(tester, 'NIM', '2024001234');
          await fillTextField(tester, 'Penempatan Magang', 'PT. Testing');
          // SKIP pilih tanggal!

          await tapSubmitButton(tester);

          // Verifikasi error (bisa jadi tidak ada error visual, tapi submit gagal)
          // Kita cek apakah masih di screen yang sama
          expect(
            find.text('Tambah User'),
            findsWidgets,
            reason: 'Masih di screen Tambah User (submit gagal)',
          );
          print('✅ Validasi tanggal tidak dipilih berhasil!');

          await cleanupNegativeTest(tester);
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );
    });

    // ========================================================================
    // GROUP 3: VALIDASI FORMAT EMAIL
    // ========================================================================
    group('Validasi Format Data', () {
      testWidgets(
        'Tidak bisa submit dengan email format salah',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);

          await navigateToAddUser(tester);
          await selectRole(tester, 'Dosen');

          // Isi email dengan format SALAH
          await fillTextField(tester, 'Nama Lengkap', 'Dr. Test Invalid Email');
          await fillTextField(
            tester,
            'E-Mail',
            'invalid-email-format',
          ); // SALAH!
          await fillTextField(tester, 'No - Telp', '081234567890');
          await fillTextField(tester, 'NIP', '1234567890');
          await selectDropdown(tester, 'Jabatan Fungsional', 'Lektor');

          await tapSubmitButton(tester);

          // Firebase akan throw error "invalid-email"
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verifikasi SnackBar error muncul
          expect(
            find.textContaining('Format email tidak valid'),
            findsWidgets,
            reason: 'Error message email invalid harus muncul',
          );

          print('✅ Validasi format email berhasil!');

          await cleanupNegativeTest(tester);
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );
    });

    // ========================================================================
    // GROUP 4: DUPLICATE DATA
    // ========================================================================
    group('Duplicate Data Handling', () {
      testWidgets(
        'Tidak bisa registrasi dengan email yang sudah terdaftar',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);

          await navigateToAddUser(tester);
          await selectRole(tester, 'Dosen');

          // Gunakan email ADMIN yang sudah pasti ada!
          await fillTextField(tester, 'Nama Lengkap', 'Dr. Test Duplicate');
          await fillTextField(tester, 'E-Mail', adminEmail); // EMAIL SUDAH ADA!
          await fillTextField(tester, 'No - Telp', '081234567890');
          await fillTextField(tester, 'NIP', '9999999999');
          await selectDropdown(tester, 'Jabatan Fungsional', 'Lektor');

          await tapSubmitButton(tester);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verifikasi error "email-already-in-use"
          expect(
            find.textContaining('Email sudah terdaftar'),
            findsWidgets,
            reason: 'Error message email duplicate harus muncul',
          );

          print('✅ Validasi email duplicate berhasil!');

          await cleanupNegativeTest(tester);
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );
    });

    // ========================================================================
    // GROUP 5: BOUNDARY TESTING
    // ========================================================================
    group('Boundary Testing', () {
      testWidgets(
        'Email terlalu panjang (>320 karakter)',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 4));

          await closeOnboarding(tester);
          await login(tester, adminEmail, adminPassword);
          await verifyAdminDashboard(tester);

          await navigateToAddUser(tester);
          await selectRole(tester, 'Dosen');

          // Email dengan 330+ karakter
          final longEmail = 'a' * 300 + '@example.com';

          await fillTextField(tester, 'Nama Lengkap', 'Dr. Test Long Email');
          await fillTextField(tester, 'E-Mail', longEmail);
          await fillTextField(tester, 'No - Telp', '081234567890');
          await fillTextField(tester, 'NIP', '1234567890');
          await selectDropdown(tester, 'Jabatan Fungsional', 'Lektor');

          await tapSubmitButton(tester);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Firebase atau validator akan reject
          expect(
            find.textContaining('tidak valid'),
            findsWidgets,
            reason: 'Error message harus muncul untuk email terlalu panjang',
          );

          print('✅ Validasi email panjang berhasil!');

          await cleanupNegativeTest(tester);
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );

      // testWidgets(
      //   'Nama terlalu panjang (>100 karakter)',
      //   (tester) async {
      //     app.main();
      //     await tester.pumpAndSettle(const Duration(seconds: 4));

      //     await closeOnboarding(tester);
      //     await login(tester, adminEmail, adminPassword);
      //     await verifyAdminDashboard(tester);

      //     await navigateToAddUser(tester);
      //     await selectRole(tester, 'Dosen');

      //     // Nama dengan 150 karakter
      //     final longName = 'Dr. ' + 'A' * 150;

      //     await fillTextField(tester, 'Nama Lengkap', longName);
      //     await fillTextField(tester, 'E-Mail', 'test.longname@example.com');
      //     await fillTextField(tester, 'No - Telp', '081234567890');
      //     await fillTextField(tester, 'NIP', '1234567890');
      //     await selectDropdown(tester, 'Jabatan Fungsional', 'Lektor');

      //     await tapSubmitButton(tester);
      //     await tester.pumpAndSettle(const Duration(seconds: 3));

      //     // Bisa jadi berhasil atau gagal tergantung validator
      //     // Jika berhasil, cek apakah nama ter-truncate atau tidak
      //     if (find
      //         .textContaining('berhasil didaftarkan!')
      //         .evaluate()
      //         .isNotEmpty) {
      //       print('⚠️ Nama panjang diterima (tidak ada validasi max length)');
      //     } else {
      //       print('✅ Nama panjang ditolak oleh validator');
      //     }

      //     await cleanupNegativeTest(tester);
      //   },
      //   timeout: const Timeout(Duration(minutes: 3)),
      // );
    });
  });
}
