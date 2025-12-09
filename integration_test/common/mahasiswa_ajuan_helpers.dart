// integration_test/common/mahasiswa_ajuan_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// =============================================================
/// ============ MAHASISWA AJUAN BIMBINGAN HELPERS ==============
/// =============================================================

/// Navigasi ke tab "Ajuan" dari Dashboard Mahasiswa
Future<void> navigateToAjuanTab(WidgetTester tester) async {
  // Tap tab "Ajuan" di BottomNavigationBar
  final ajuanTab = find.text('Ajuan');

  expect(
    ajuanTab,
    findsOneWidget,
    reason: 'Tab "Ajuan" tidak ditemukan di BottomNavigationBar',
  );

  await tester.tap(ajuanTab);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  print('✅ Navigasi ke tab "Ajuan" berhasil.');
}

/// Navigasi ke halaman Create Ajuan Bimbingan (dari Riwayat Ajuan Screen)
/// Mencari FAB atau tombol "Ajukan Bimbingan"
Future<void> navigateToCreateAjuan(WidgetTester tester) async {
  // Cari FAB dengan ikon add atau text "Ajukan"
  final fab = find.byType(FloatingActionButton);

  if (fab.evaluate().isNotEmpty) {
    await tester.tap(fab);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    print('✅ Tap FAB untuk buat ajuan baru.');
  } else {
    // Fallback: Cari tombol dengan text yang mengandung "Ajukan"
    final ajukanButton = find.textContaining('Ajukan');

    expect(
      ajukanButton,
      findsOneWidget,
      reason: 'Tombol "Ajukan Bimbingan" tidak ditemukan',
    );

    await tester.tap(ajukanButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    print('✅ Tap tombol "Ajukan Bimbingan".');
  }

  // Verifikasi sudah di halaman Ajuan Bimbingan
  expect(
    find.text('Ajuan Bimbingan'),
    findsWidgets,
    reason: 'Gagal navigasi ke halaman Ajuan Bimbingan',
  );

  print('✅ Berhasil ke halaman "Ajuan Bimbingan".');
}

/// Indeks TextField di MahasiswaAjuanScreen
/// - [0] Mahasiswa (readonly)
/// - [1] Dosen Pembimbing (readonly)
/// - [2] Topik Bimbingan
/// - [3] Metode Bimbingan
/// - [4] Waktu Bimbingan (readonly, onTap)
/// - [5] Tanggal Bimbingan (readonly, onTap)
const int _idxTopik = 2;
const int _idxMetode = 3;
const int _idxWaktu = 4;
const int _idxTanggal = 5;

/// Isi form Ajuan Bimbingan dengan data lengkap
Future<void> fillAjuanForm({
  required WidgetTester tester,
  required String topik,
  required String metode,
  bool selectWaktu = true,
  bool selectTanggal = true,
}) async {
  final inputFields = find.byType(TextField);

  // 1. Isi Topik Bimbingan (Index 2)
  await tester.ensureVisible(inputFields.at(_idxTopik));
  await tester.enterText(inputFields.at(_idxTopik), topik);
  await tester.pumpAndSettle();
  print('✅ Topik diisi: $topik');

  // 2. Isi Metode Bimbingan (Index 3)
  await tester.ensureVisible(inputFields.at(_idxMetode));
  await tester.enterText(inputFields.at(_idxMetode), metode);
  await tester.pumpAndSettle();
  print('✅ Metode diisi: $metode');

  // 3. Pilih Waktu (Index 4)
  if (selectWaktu) {
    await _selectWaktu(tester);
  }

  // 4. Pilih Tanggal (Index 5)
  if (selectTanggal) {
    await _selectTanggal(tester);
  }
}

/// Helper untuk memilih waktu bimbingan
Future<void> _selectWaktu(WidgetTester tester) async {
  final inputFields = find.byType(TextField);

  // Tap field waktu untuk buka TimePicker
  await tester.ensureVisible(inputFields.at(_idxWaktu));
  await tester.tap(inputFields.at(_idxWaktu));
  await tester.pumpAndSettle(const Duration(seconds: 1));

  // Tap tombol OK di TimePicker
  final okButton = find.text('OK');

  if (okButton.evaluate().isNotEmpty) {
    await tester.tap(okButton);
    await tester.pumpAndSettle();
    print('✅ Waktu bimbingan dipilih.');
  } else {
    print('⚠️ TimePicker tidak muncul, skip pilih waktu.');
  }
}

/// Helper untuk memilih tanggal bimbingan
Future<void> _selectTanggal(WidgetTester tester) async {
  final inputFields = find.byType(TextField);

  // Tap field tanggal untuk buka DatePicker
  await tester.ensureVisible(inputFields.at(_idxTanggal));
  await tester.tap(inputFields.at(_idxTanggal));
  await tester.pumpAndSettle(const Duration(seconds: 1));

  // Tap tombol OK di DatePicker
  final okButton = find.text('OK');

  if (okButton.evaluate().isNotEmpty) {
    await tester.tap(okButton);
    await tester.pumpAndSettle();
    print('✅ Tanggal bimbingan dipilih.');
  } else {
    print('⚠️ DatePicker tidak muncul, skip pilih tanggal.');
  }
}

/// Submit form Ajuan Bimbingan
Future<void> submitAjuan(WidgetTester tester) async {
  // Scroll ke bawah untuk memastikan tombol Submit terlihat
  await tester.drag(
    find.byType(SingleChildScrollView).first,
    const Offset(0.0, -200.0),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // Tap tombol Submit
  final submitButton = find.widgetWithText(ElevatedButton, 'Submit');

  expect(
    submitButton,
    findsOneWidget,
    reason: 'Tombol "Submit" tidak ditemukan',
  );

  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton);
  await tester.pumpAndSettle(const Duration(seconds: 3));

  print('✅ Tombol Submit ditekan.');
}

/// Verifikasi Success Screen muncul setelah submit
Future<void> verifySuccessScreen(WidgetTester tester) async {
  // Cari text sukses message
  final successMessage = find.textContaining('Ajuan Bimbingan Berhasil');

  expect(
    successMessage,
    findsOneWidget,
    reason: 'Success message tidak muncul',
  );

  print('✅ Success Screen terdeteksi: Ajuan berhasil diajukan.');
}

/// Tap tombol "Kembali" di Success Screen
Future<void> tapKembaliFromSuccess(WidgetTester tester) async {
  final kembaliButton = find.widgetWithText(ElevatedButton, 'Kembali');

  expect(
    kembaliButton,
    findsOneWidget,
    reason: 'Tombol "Kembali" tidak ditemukan di Success Screen',
  );

  await tester.tap(kembaliButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  print('✅ Kembali dari Success Screen.');
}

/// Verifikasi validation error muncul di form
Future<void> verifyAjuanValidationError(
  WidgetTester tester,
  String expectedError,
) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  final errorFinder = find.textContaining(expectedError);

  expect(
    errorFinder,
    findsWidgets,
    reason: 'Error message "$expectedError" tidak ditemukan',
  );

  print('✅ Validation error terdeteksi: $expectedError');
}

/// Verifikasi masih di halaman Ajuan Bimbingan (submit gagal)
Future<void> verifyStillOnAjuanPage(WidgetTester tester) async {
  expect(
    find.text('Ajuan Bimbingan'),
    findsWidgets,
    reason: 'Masih di halaman "Ajuan Bimbingan" (submit gagal)',
  );

  print('✅ Masih di halaman Ajuan Bimbingan (submit gagal).');
}

/// Cleanup untuk negative test: Kembali ke Riwayat Ajuan Screen
Future<void> cleanupAjuanTest(WidgetTester tester) async {
  // Tap back button jika masih di MahasiswaAjuanScreen
  final backButton = find.byType(BackButton);

  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    print('🔙 Kembali ke Riwayat Ajuan screen.');
  }

  Future<void> logoutMahasiswaViaProfile(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    final profilTab = find.text('Profil');
    if (profilTab.evaluate().isEmpty) {
      print('⚠️ [Mahasiswa] Tab "Profil" tidak ditemukan — skip logout.');
      return;
    }

    await tester.tap(profilTab.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    if (find.text('Profil').evaluate().isEmpty) {
      print('⚠️ [Mahasiswa] Judul Profil tidak terdeteksi — skip logout.');
      return;
    }

    final logoutIcon = find.byIcon(Icons.logout);
    if (logoutIcon.evaluate().isEmpty) {
      print('⚠️ [Mahasiswa] Ikon logout tidak ditemukan — skip logout.');
      return;
    }

    await tester.tap(logoutIcon.first);
    await tester.pumpAndSettle();

    final confirmButton = find.widgetWithText(ElevatedButton, 'Logout');
    if (confirmButton.evaluate().isEmpty) {
      print('⚠️ [Mahasiswa] Tombol Logout tidak ditemukan — skip logout.');
      return;
    }

    await tester.tap(confirmButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ✅ ASSERT LOGIN PAGE TANPA Finder.or
    final isOnLoginPage =
        find.text('Selamat Datang').evaluate().isNotEmpty ||
        find.text('Masuk ke akun Anda').evaluate().isNotEmpty;

    expect(
      isOnLoginPage,
      true,
      reason: '[Mahasiswa] Gagal kembali ke halaman login setelah logout',
    );

    print('✅ [Mahasiswa] Logout berhasil (via helper).');
  }
}
