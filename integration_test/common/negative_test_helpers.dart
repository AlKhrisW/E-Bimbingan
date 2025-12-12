// File: integration_test/common/negative_test_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// =============================================================
/// ================ NAVIGATION HELPERS (NEGATIVE) ==============
/// =============================================================

/// Navigasi ke halaman Tambah User dari Dashboard Admin
Future<void> navigateToAddUser(WidgetTester tester) async {
  // ... (kode navigateToAddUser tetap sama)
  // 1. Tap tab "Users"
  final usersTab = find.byIcon(Icons.manage_accounts_outlined);
  await tester.tap(usersTab);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // 2. Tap FAB Tambah User
  final fab = find.byKey(const ValueKey('add_user')).hitTestable();
  await tester.tap(fab);
  await tester.pumpAndSettle(const Duration(seconds: 1));

  // 3. Verifikasi sudah di halaman Tambah User
  expect(
    find.text('Tambah Pengguna Baru').or(find.text('Edit Pengguna')),
    findsWidgets,
  );
}

/// Navigasi ke Profile dan Logout
Future<void> navigateToProfileAndLogout(WidgetTester tester) async {
  // ... (kode navigateToProfileAndLogout tetap sama)
  // Cek apakah sudah di screen dengan BottomNavigationBar
  final profileTab = find.text('Akun');

  if (profileTab.evaluate().isEmpty) {
    // Jika tidak ada tab Akun, berarti masih di RegisterUserScreen
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  // Sekarang tap tab Akun
  await tester.tap(profileTab);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Tap ikon logout
  final logoutIcon = find.byIcon(Icons.logout);
  await tester.tap(logoutIcon);
  await tester.pumpAndSettle();

  // Tap tombol konfirmasi logout
  final logoutButton = find.descendant(
    of: find.byType(BottomSheet),
    matching: find.text('Logout'),
  );

  final confirmButton = logoutButton.evaluate().isNotEmpty
      ? logoutButton.first
      : find.text('Logout').last;

  await tester.tap(confirmButton);
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Verifikasi sudah di login page
  expect(
    find.text('Selamat Datang').or(find.text('Masuk ke akun Anda')),
    findsWidgets,
  );
}

/// Cleanup untuk negative test (tanpa logout penuh)
Future<void> cleanupNegativeTest(WidgetTester tester) async {
  // ... (kode cleanupNegativeTest tetap sama)
  // Tap back button jika masih di RegisterUserScreen
  final backButton = find.byType(BackButton);

  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    print('🔙 Kembali ke Users screen');
  }

  // TIDAK perlu logout, biarkan setUp() di test berikutnya yang handle
}

/// =============================================================
/// ================ FORM INTERACTION HELPERS ===================
/// =============================================================

/// Pilih Role dari Dropdown (Mahasiswa/Dosen/Admin)
Future<void> selectRole(WidgetTester tester, String role) async {
  // ... (kode selectRole tetap sama)
  // Tap dropdown role (cari by text Mahasiswa yang pertama)
  final roleDropdown = find.text('Mahasiswa').first;
  await tester.tap(roleDropdown);
  await tester.pumpAndSettle();

  // Pilih role (ambil yang terakhir karena dropdown items muncul belakangan)
  await tester.tap(find.text(role).last);
  await tester.pumpAndSettle(const Duration(milliseconds: 700));
}

/// Isi TextField berdasarkan label
Future<void> fillTextField(
  WidgetTester tester,
  String label,
  String value,
) async {
  // ... (kode fillTextField tetap sama)
  // Cari TextField yang ada di dalam TextFormField dengan cara mencari descendant
  final allFields = find.byType(TextFormField);
  bool found = false;

  for (int i = 0; i < allFields.evaluate().length; i++) {
    try {
      // Cari TextField di dalam TextFormField
      final textFieldFinder = find.descendant(
        of: allFields.at(i),
        matching: find.byType(TextField),
      );

      if (textFieldFinder.evaluate().isEmpty) continue;

      // Ambil TextField widget
      final textFieldWidget = tester.widget<TextField>(textFieldFinder.first);
      final decoration = textFieldWidget.decoration as InputDecoration?;

      // FIX: Gunakan labelText untuk mencari field, bukan Program Studi/Jurusan yang mungkin sudah jadi Dropdown
      if (decoration?.labelText == label) {
        await tester.ensureVisible(allFields.at(i));
        await tester.enterText(allFields.at(i), value);
        await tester.pumpAndSettle();
        found = true;
        break;
      }
    } catch (e) {
      // Skip jika widget tidak bisa dicast
      continue;
    }
  }

  if (!found) {
    throw Exception('TextField dengan label "$label" tidak ditemukan');
  }
}

/// Pilih item dari Dropdown berdasarkan label dropdown
Future<void> selectDropdown(
  WidgetTester tester,
  String dropdownLabel,
  String itemValue,
) async {
  // ... (kode selectDropdown tetap sama)
  // Scroll agar dropdown terlihat
  await tester.drag(
    find.byType(SingleChildScrollView).first,
    const Offset(0.0, -150.0),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // Tap dropdown (Cari label dropdown)
  final dropdown = find.text(dropdownLabel);
  expect(
    dropdown,
    findsWidgets,
    reason: 'Dropdown "$dropdownLabel" tidak ditemukan',
  );

  await tester.ensureVisible(dropdown.first);
  await tester.tap(dropdown.first);
  await tester.pumpAndSettle();

  // Pilih item (ambil yang terakhir karena dropdown items muncul belakangan)
  await tester.tap(find.text(itemValue).last);
  await tester.pumpAndSettle();
}

/// Pilih tanggal mulai untuk Mahasiswa
Future<void> selectStartDate(WidgetTester tester) async {
  // ... (kode selectStartDate tetap sama)
  // Cari tile "Tanggal Mulai Magang"
  final dateTile = find.text('Tanggal Mulai Magang');

  if (dateTile.evaluate().isNotEmpty) {
    await tester.ensureVisible(dateTile.first);
    await tester.tap(dateTile.first);
    await tester.pumpAndSettle();

    // Tap tombol OK di DatePicker
    final okButton = find.text('OK');
    if (okButton.evaluate().isNotEmpty) {
      await tester.tap(okButton);
      await tester.pumpAndSettle();
    }
  }
}

/// Tap tombol Submit (Tambah User)
Future<void> tapSubmitButton(WidgetTester tester) async {
  // ... (kode tapSubmitButton tetap sama)
  final submitButton = find.widgetWithText(ElevatedButton, 'Tambah User');

  // Paksa scroll ke tombol submit
  await tester.dragUntilVisible(
    submitButton,
    find.byType(SingleChildScrollView).first,
    const Offset(
      0.0,
      100.0,
    ), // Scroll ke atas 100 unit untuk memastikan tombol dan error field terlihat
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// =============================================================
/// ================ VALIDATION HELPERS =========================
/// =============================================================

/// Verifikasi error validation muncul di layar
Future<void> verifyValidationError(
  WidgetTester tester,
  String expectedError,
) async {
  // ... (kode verifyValidationError tetap sama)
  // Tunggu sebentar agar error muncul
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // Cari error message (bisa di form field atau SnackBar)
  final errorFinder = find.textContaining(expectedError);

  expect(
    errorFinder,
    findsWidgets,
    reason: 'Error message "$expectedError" tidak ditemukan',
  );
}

/// Verifikasi SnackBar error muncul
Future<void> verifyErrorSnackBar(
  WidgetTester tester,
  String expectedMessage,
) async {
  // ... (kode verifyErrorSnackBar tetap sama)
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(
    find.textContaining(expectedMessage),
    findsWidgets,
    reason: 'SnackBar error "$expectedMessage" tidak muncul',
  );
}

/// =============================================================
/// ================ FINDER EXTENSIONS (PERBAIKAN) ==============
/// =============================================================

// DEFINISI FINDERX DIPINDAH KE SINI AGAR TIDAK ADA ERROR 'OR'
extension FinderX on Finder {
  Finder or(Finder other) => _OrFinder(this, other);
}

class _OrFinder extends Finder {
  final Finder _first;
  final Finder _second;
  _OrFinder(this._first, this._second);

  @override
  String get description => '${_first.description} OR ${_second.description}';

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    final firstResults = _first.apply(candidates).toSet();
    final secondResults = _second.apply(candidates).toSet();
    return {...firstResults, ...secondResults};
  }
}
