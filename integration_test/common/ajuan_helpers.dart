import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';
import 'package:ebimbingan/core/widgets/custom_FAB_button.dart';

/// Helper universal untuk navigasi kembali
Future<void> navigateBack(
  WidgetTester tester, {
  String? customButtonText,
}) async {
  if (customButtonText != null) {
    final customButton = find.widgetWithText(ElevatedButton, customButtonText);
    if (customButton.evaluate().isNotEmpty) {
      await tester.tap(customButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      return;
    }
  }

  final chevronLeftIcon = find.byIcon(Icons.chevron_left);
  if (chevronLeftIcon.evaluate().isNotEmpty) {
    await tester.tap(chevronLeftIcon.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    return;
  }

  final backButton = find.byType(BackButton);
  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    return;
  }

  final appBarBackIcon = find.descendant(
    of: find.byType(AppBar),
    matching: find.byIcon(Icons.arrow_back),
  );
  if (appBarBackIcon.evaluate().isNotEmpty) {
    await tester.tap(appBarBackIcon.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    return;
  }

  final backIcon = find.byIcon(Icons.arrow_back);
  if (backIcon.evaluate().isNotEmpty) {
    await tester.tap(backIcon.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    return;
  }

  try {
    final BuildContext context = tester.element(find.byType(Scaffold).first);
    Navigator.of(context).pop();
    await tester.pumpAndSettle(const Duration(seconds: 1));
  } catch (e) {
    final leadingButtons = find.descendant(
      of: find.byType(AppBar),
      matching: find.byType(IconButton),
    );
    if (leadingButtons.evaluate().isNotEmpty) {
      await tester.tap(leadingButtons.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
  }
}

Future<void> verifyMahasiswaDashboard(WidgetTester tester) async {
  expect(find.text('Jadwal Bimbingan'), findsWidgets);
  expect(find.text('Laporan Bimbingan Magang'), findsWidgets);
  expect(find.text('Aktivitas Bimbingan'), findsWidgets);
}

Future<void> logoutViaProfileMahasiswa(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 2));

  final profileTab = find.text('Profil');
  expect(profileTab, findsOneWidget);
  await tester.tap(profileTab.first);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  final logoutIcon = find.byIcon(Icons.logout);
  expect(logoutIcon, findsOneWidget);
  await tester.tap(logoutIcon);
  await tester.pumpAndSettle(const Duration(seconds: 1));

  Finder confirmButton = find.widgetWithText(ElevatedButton, 'Logout');
  if (confirmButton.evaluate().isEmpty) {
    final inSheet = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('Logout'),
    );
    confirmButton = inSheet.evaluate().isNotEmpty
        ? inSheet.first
        : find.text('Logout').last;
  }

  expect(confirmButton, findsOneWidget);
  await tester.tap(confirmButton);
  await tester.pumpAndSettle(const Duration(seconds: 3));

  expect(
    find.text('Selamat Datang').or(find.text('Masuk ke akun Anda')),
    findsWidgets,
  );
}

Future<void> navigateToAjuanHistory(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 2));

  final ajuanTab = find.text('Ajuan');
  expect(ajuanTab, findsOneWidget);
  await tester.tap(ajuanTab);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('Riwayat Ajuan'), findsOneWidget);
}

Future<void> navigateToTambahAjuan(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 3));
  expect(find.text('Riwayat Ajuan'), findsOneWidget);

  Finder fabFinder = find.descendant(
    of: find.byType(FloatingActionButton),
    matching: find.byIcon(Icons.add),
  );

  if (fabFinder.evaluate().isEmpty) {
    fabFinder = find.byType(CustomAddFab);
  }
  if (fabFinder.evaluate().isEmpty) {
    fabFinder = find.byType(FloatingActionButton);
  }
  if (fabFinder.evaluate().isEmpty) {
    fabFinder = find.byIcon(Icons.add);
  }

  if (fabFinder.evaluate().isEmpty) {
    await tester.pumpAndSettle(const Duration(seconds: 3));
    fabFinder = find.byType(FloatingActionButton);
  }

  expect(fabFinder, findsOneWidget);
  await tester.tap(fabFinder.first);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('Ajuan Bimbingan Baru'), findsOneWidget);
}

Future<void> fillAjuanForm(
  WidgetTester tester, {
  required String topik,
  required String metode,
}) async {
  await tester.pumpAndSettle(const Duration(seconds: 1));

  final topikField = find.byType(TextFormField).at(0);
  expect(topikField, findsOneWidget);
  await tester.enterText(topikField, topik);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  final metodeField = find.byType(TextFormField).at(1);
  expect(metodeField, findsOneWidget);
  await tester.enterText(metodeField, metode);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  await selectNextDay(tester);
  await confirmTime(tester);
}

Future<void> selectNextDay(WidgetTester tester) async {
  final datePickerField = find
      .descendant(
        of: find.ancestor(
          of: find.text('Tanggal'),
          matching: find.byType(Column),
        ),
        matching: find.byType(InkWell),
      )
      .first;

  await tester.tap(datePickerField);
  await tester.pumpAndSettle(const Duration(seconds: 1));

  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final dayText = tomorrow.day.toString();
  final tomorrowFinder = find.text(dayText).last;
  await tester.tap(tomorrowFinder);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  final okButton = find.text('OK').or(find.text('SET'));
  if (okButton.evaluate().isNotEmpty) {
    await tester.tap(okButton.first);
  }
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

Future<void> confirmTime(WidgetTester tester) async {
  final timePickerField = find
      .descendant(
        of: find.ancestor(of: find.text('Jam'), matching: find.byType(Column)),
        matching: find.byType(InkWell),
      )
      .first;

  await tester.tap(timePickerField);
  await tester.pumpAndSettle(const Duration(seconds: 1));

  final okButton = find.text('OK').or(find.text('SET'));
  if (okButton.evaluate().isNotEmpty) {
    await tester.tap(okButton.first);
  }
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

Future<void> submitAjuan(WidgetTester tester) async {
  final submitButton = find.widgetWithText(ElevatedButton, 'Kirim Ajuan');
  expect(submitButton, findsOneWidget);
  await tester.tap(submitButton);
  await tester.pumpAndSettle(const Duration(seconds: 4));
}

Future<void> verifySubmissionSuccess(WidgetTester tester) async {
  expect(find.text('Ajuan Bimbingan Berhasil Dikirim'), findsOneWidget);
  await navigateBack(tester, customButtonText: 'Kembali');
  expect(find.text('Riwayat Ajuan'), findsOneWidget);
}

Future<void> verifyNewAjuanInList(WidgetTester tester, String topik) async {
  await tester.pumpAndSettle(const Duration(seconds: 2));

  try {
    await tester.scrollUntilVisible(
      find.text(topik),
      50.0,
      scrollable: find.byType(Scrollable).first,
    );
  } catch (e) {
    // Item already visible
  }

  expect(find.text(topik), findsOneWidget);
  await tester.tap(find.text(topik));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.text('Detail Ajuan Bimbingan'), findsOneWidget);
  expect(find.text('Menunggu Persetujuan'), findsOneWidget);

  await navigateBack(tester);
  expect(find.text('Riwayat Ajuan'), findsOneWidget);
}

Future<void> verifyErrorSnackBar(
  WidgetTester tester,
  String expectedMessage,
) async {
  await tester.pump(const Duration(milliseconds: 500));
  expect(find.textContaining(expectedMessage), findsOneWidget);
}
