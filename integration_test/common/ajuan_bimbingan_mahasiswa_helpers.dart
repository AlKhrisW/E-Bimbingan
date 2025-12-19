// integration_test/common/ajuan_bimbingan_mahasiswa_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'test_helpers.dart';

class AjuanBimbinganMahasiswaHelpers {
  // Finder utama
  static final Finder tabAjuan = find.text('Ajuan');
  static final Finder titleRiwayatAjuan = find.text('Riwayat Ajuan');
  static final Finder successMessage = find.text(
    'Ajuan Bimbingan Berhasil Dikirim',
  );
  static final Finder backButtonSuccess = find.text(
    'Kembali',
  ); // Tombol di SuccessScreen

  // FAB finder fleksibel (dari helper lama yang terbukti)
  static Finder get fabAdd {
    Finder finder = find.descendant(
      of: find.byType(FloatingActionButton),
      matching: find.byIcon(Icons.add),
    );
    if (finder.evaluate().isEmpty) {
      finder = find.byType(FloatingActionButton);
    }
    return finder;
  }

  // TextFormField
  static Finder fieldTopik = find.byType(TextFormField).at(0);
  static Finder fieldMetode = find.byType(TextFormField).at(1);

  // Date & Time Picker akurat (dari helper lama yang sudah terbukti)
  static Finder datePicker = find
      .descendant(
        of: find.ancestor(
          of: find.text('Tanggal'),
          matching: find.byType(Column),
        ),
        matching: find.byType(InkWell),
      )
      .first;

  static Finder timePicker = find
      .descendant(
        of: find.ancestor(of: find.text('Jam'), matching: find.byType(Column)),
        matching: find.byType(InkWell),
      )
      .first;

  static Finder buttonKirim = find.text('Kirim Ajuan');

  /// Buka halaman Riwayat Ajuan dari bottom nav
  static Future<void> bukaHalamanRiwayatAjuan(WidgetTester tester) async {
    await tester.tap(tabAjuan);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Tunggu FAB muncul setelah load data
    await tester.pumpUntilFound(fabAdd, timeout: const Duration(seconds: 15));

    expect(titleRiwayatAjuan, findsOneWidget);
  }

  /// Buat ajuan baru dan kembali ke riwayat setelah success
  static Future<void> buatAjuanBaru({
    required WidgetTester tester,
    required String topik,
    required String metode,
    DateTime? tanggal,
    TimeOfDay? waktu,
  }) async {
    // Pastikan FAB ada
    expect(fabAdd, findsOneWidget);
    await tester.tap(fabAdd.first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Tunggu form
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.textContaining('Dosen Pembimbing'), findsOneWidget);
    expect(find.text('Ajuan Bimbingan Baru'), findsOneWidget);

    // Isi form
    await tester.enterText(fieldTopik, topik);
    await tester.pumpAndSettle();

    await tester.enterText(fieldMetode, metode);
    await tester.pumpAndSettle();

    // Pilih tanggal (besok)
    await tester.tap(datePicker);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await tester.tap(find.text('${tomorrow.day}').last);
    await tester.pumpAndSettle();

    final okButton = find.text('OK');
    if (okButton.evaluate().isNotEmpty) {
      await tester.tap(okButton.first);
    }
    await tester.pumpAndSettle();

    // Pilih jam (langsung OK default)
    await tester.tap(timePicker);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final okTimeButton = find.text('OK');
    if (okTimeButton.evaluate().isNotEmpty) {
      await tester.tap(okTimeButton.first);
    }
    await tester.pumpAndSettle();

    // Submit
    await tester.scrollUntilVisible(
      buttonKirim,
      100.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(buttonKirim);
    await tester.pumpAndSettle(const Duration(seconds: 6));

    // Success screen
    expect(successMessage, findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // KEMBALI KE RIWAYAT AJUAN DENGAN TAP TOMBOL "KEMBALI"
    await tester.tap(backButtonSuccess);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Pastikan sudah kembali ke riwayat
    expect(titleRiwayatAjuan, findsOneWidget);
  }

  /// Verifikasi ajuan muncul (sudah di riwayat setelah kembali dari success)
  static Future<void> verifikasiAjuanMunculDiRiwayat(
    WidgetTester tester,
    String topik,
  ) async {
    // Sudah berada di Riwayat Ajuan
    expect(titleRiwayatAjuan, findsOneWidget);

    // Refresh list
    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 400));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // Scroll jika perlu
    try {
      await tester.scrollUntilVisible(find.text(topik), 100.0);
    } catch (e) {
      // Already visible
    }

    expect(find.text(topik), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
  }

  /// Buka detail ajuan
  static Future<void> bukaDetailAjuan(WidgetTester tester, String topik) async {
    await tester.tap(find.text(topik));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Detail Ajuan Bimbingan'), findsOneWidget);
    expect(find.text(topik), findsOneWidget);
  }
}
