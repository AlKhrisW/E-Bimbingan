// integration_test/common/dosen_ajuan_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DosenAjuanHelpers {
  static final Finder tabAjuan = find.text('Ajuan');
  static final Finder tabRiwayat = find.text('Riwayat');
  static final Finder titleAjuanMasuk = find.text('Ajuan Masuk');

  static final Finder statusDisetujui = find.text('Disetujui');

  static Future<void> bukaHalamanAjuanMasuk(WidgetTester tester) async {
    await tester.tap(tabAjuan);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(titleAjuanMasuk, findsOneWidget);
  }

  static Future<void> bukaDetailAjuan(WidgetTester tester, String topik) async {
    final card = find.textContaining(topik);
    expect(card, findsOneWidget);
    await tester.tap(card);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Detail Ajuan Bimbingan'), findsOneWidget);
  }

  static Future<void> approveAjuan(WidgetTester tester) async {
    final buttonTerima = find.text('Terima');
    expect(buttonTerima, findsOneWidget);
    await tester.tap(buttonTerima);
    await tester.pumpAndSettle(const Duration(seconds: 6));
    expect(titleAjuanMasuk, findsOneWidget);
  }

  static Future<void> verifikasiAjuanHilang(
    WidgetTester tester,
    String topik,
  ) async {
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.textContaining(topik), findsNothing);
  }

  static Future<void> verifikasiDiRiwayat(
    WidgetTester tester,
    String topik,
  ) async {
    await tester.tap(tabRiwayat);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Tap card mahasiswa berdasarkan nama "e2e test" — finder teks langsung
    final cardMahasiswa = find.textContaining('e2e test');
    expect(cardMahasiswa, findsOneWidget);
    await tester.tap(cardMahasiswa);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Langsung verifikasi topik dan status ada di layar (tidak perlu scroll)
    expect(find.textContaining(topik), findsAtLeastNWidgets(1));
    expect(statusDisetujui, findsOneWidget);
  }
}
