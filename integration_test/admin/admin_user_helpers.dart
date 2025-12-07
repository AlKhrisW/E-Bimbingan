// integration_test/admin/admin_user_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// =============================================================
/// ===================== ADMIN ADD USER HELPER ==================
/// =============================================================

// Indeks untuk mode DOSEN (berdasarkan urutan TextFormField di RegisterUserScreen.dart)
const int _idxName = 0;
const int _idxEmailDosen = 1;
const int _idxPhoneDosen = 2;
// Index 3 adalah Password Default (Disabled)
const int _idxNipDosen = 4; // Index 4 setelah Password Disabled

/// Mengisi dan Submit form registrasi Dosen
Future<void> fillAndSubmitDosenForm({
  required WidgetTester tester,
  required String name,
  required String email,
  required String phone,
  required String nip,
  required String jabatan,
}) async {
  // 1. Pilih Role: Dosen
  final roleDropdown = find.text('Mahasiswa').first;
  await tester.tap(roleDropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Dosen').last);
  await tester.pumpAndSettle(
    const Duration(milliseconds: 700),
  ); // Tunggu rendering field Dosen

  // Ambil semua TextFormField yang terlihat (termasuk yang Disabled)
  final inputFields = find.byType(TextFormField);

  // 2. Isi Data Umum (Menggunakan Index)

  // --- NAMA (Index 0) ---
  await tester.ensureVisible(inputFields.at(_idxName));
  await tester.enterText(inputFields.at(_idxName), name);
  await tester.pumpAndSettle();

  // --- EMAIL (Index 1) ---
  await tester.ensureVisible(inputFields.at(_idxEmailDosen));
  await tester.enterText(inputFields.at(_idxEmailDosen), email);
  await tester.pumpAndSettle();

  // --- PHONE (Index 2) ---
  await tester.ensureVisible(inputFields.at(_idxPhoneDosen));
  await tester.enterText(inputFields.at(_idxPhoneDosen), phone);
  await tester.pumpAndSettle();

  // 3. Isi NIP (Index 4)
  await tester.ensureVisible(inputFields.at(_idxNipDosen));
  await tester.enterText(inputFields.at(_idxNipDosen), nip);
  await tester.pumpAndSettle();

  // 4. Pilih Jabatan (Dropdown)

  // Finder yang benar: Jabatan Fungsional (Memperbaiki error sebelumnya)
  final jabatanDropdownLabel = find.text('Jabatan Fungsional');

  // Scroll manual agar pasti terlihat
  await tester.drag(
    find.byType(SingleChildScrollView).first,
    const Offset(0.0, -100.0),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  expect(
    jabatanDropdownLabel,
    findsOneWidget,
    reason: 'Dropdown "Jabatan Fungsional" tidak ditemukan.',
  );

  await tester.ensureVisible(jabatanDropdownLabel);
  await tester.tap(jabatanDropdownLabel);
  await tester.pumpAndSettle();

  // Tap item Jabatan
  await tester.tap(find.text(jabatan).last);
  await tester.pumpAndSettle();

  // 5. Submit
  // Mengatasi ambiguitas tap dengan menargetkan ElevatedButton
  await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah User'));
  await tester.pumpAndSettle(const Duration(seconds: 5));
}
