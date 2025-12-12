import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'ajuan_helpers.dart';

/// Helper untuk mencari teks error yang ditampilkan di UI (via errorText VM)
Future<void> verifyVmError(WidgetTester tester, String expectedMessage) async {
  await tester.pump(const Duration(milliseconds: 500));
  expect(
    find.textContaining(expectedMessage),
    findsOneWidget,
    reason: 'Error message tidak muncul: $expectedMessage',
  );
}

Future<void> testSubmitEmptyForm(WidgetTester tester) async {
  await navigateToTambahAjuan(tester);
  await submitAjuan(tester);
  await tester.pump(const Duration(seconds: 1));

  await verifyVmError(tester, 'Topik wajib diisi');
  await verifyVmError(tester, 'Metode wajib diisi');

  await navigateBack(tester);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> testSubmitOnlyTopik(WidgetTester tester) async {
  await navigateToTambahAjuan(tester);
  final topikField = find.byType(TextFormField).at(0);
  await tester.enterText(topikField, 'Test Topik Saja');
  await tester.pump(const Duration(milliseconds: 500));
  await submitAjuan(tester);
  await tester.pump(const Duration(seconds: 1));

  await verifyVmError(tester, 'Metode wajib diisi');
  expect(find.text('Topik wajib diisi'), findsNothing);

  await navigateBack(tester);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> testSubmitOnlyMetode(WidgetTester tester) async {
  await navigateToTambahAjuan(tester);
  final metodeField = find.byType(TextFormField).at(1);
  await tester.enterText(metodeField, 'Google Meet');
  await tester.pump(const Duration(milliseconds: 500));
  await submitAjuan(tester);
  await tester.pump(const Duration(seconds: 1));

  await verifyVmError(tester, 'Topik wajib diisi');
  expect(find.text('Metode wajib diisi'), findsNothing);

  await navigateBack(tester);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> testSubmitTopikWhitespace(WidgetTester tester) async {
  await navigateToTambahAjuan(tester);
  final topikField = find.byType(TextFormField).at(0);
  await tester.enterText(topikField, '   ');
  final metodeField = find.byType(TextFormField).at(1);
  await tester.enterText(metodeField, 'Tatap Muka');
  await submitAjuan(tester);
  await tester.pump(const Duration(seconds: 1));

  await verifyVmError(tester, 'Topik wajib diisi');

  await navigateBack(tester);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> testSubmitMetodeWhitespace(WidgetTester tester) async {
  await navigateToTambahAjuan(tester);
  final topikField = find.byType(TextFormField).at(0);
  await tester.enterText(topikField, 'Konsultasi Bab 1');
  final metodeField = find.byType(TextFormField).at(1);
  await tester.enterText(metodeField, '   ');
  await submitAjuan(tester);
  await tester.pump(const Duration(seconds: 1));

  await verifyVmError(tester, 'Metode wajib diisi');

  await navigateBack(tester);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> testSubmitTopikTooShort(WidgetTester tester) async {
  await navigateToTambahAjuan(tester);
  final topikField = find.byType(TextFormField).at(0);
  await tester.enterText(topikField, 'AB');
  final metodeField = find.byType(TextFormField).at(1);
  await tester.enterText(metodeField, 'Tatap Muka');
  await submitAjuan(tester);
  await tester.pump(const Duration(seconds: 1));

  await verifyVmError(tester, 'Topik minimal 5 karakter');

  await navigateBack(tester);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> testSubmitTopikTooLong(WidgetTester tester) async {
  await navigateToTambahAjuan(tester);
  final longTopik = 'Lorem ipsum dolor sit amet ' * 10;
  final topikField = find.byType(TextFormField).at(0);
  await tester.enterText(topikField, longTopik);
  final metodeField = find.byType(TextFormField).at(1);
  await tester.enterText(metodeField, 'Tatap Muka');
  await submitAjuan(tester);
  await tester.pump(const Duration(seconds: 1));

  await verifyVmError(tester, 'Topik maksimal 255 karakter');

  await navigateBack(tester);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> testSubmitWithSpecialCharacters(WidgetTester tester) async {
  await navigateToTambahAjuan(tester);
  final topikField = find.byType(TextFormField).at(0);
  await tester.enterText(topikField, 'Konsultasi #Bab1 @Dosen!!!');
  final metodeField = find.byType(TextFormField).at(1);
  await tester.enterText(metodeField, 'Google Meet');
  await submitAjuan(tester);
  await tester.pump(const Duration(seconds: 1));

  await verifyVmError(tester, 'Topik mengandung karakter tidak diizinkan.');

  await navigateBack(tester);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> testCancelFormMidway(WidgetTester tester) async {
  await navigateToTambahAjuan(tester);
  final topikField = find.byType(TextFormField).at(0);
  await tester.enterText(topikField, 'Form yang akan dicancel');
  await tester.pump(const Duration(milliseconds: 500));

  await navigateBack(tester);
  await tester.pumpAndSettle(const Duration(seconds: 1));
  expect(find.text('Riwayat Ajuan'), findsOneWidget);
}
