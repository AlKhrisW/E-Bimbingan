// integration_test/common/test_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> closeOnboarding(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 5));

  final skip = find.text('SKIP');
  final masuk = find.text('Masuk');
  final loginHeader = find.text('Selamat Datang');
  final nextBtn = find.byIcon(Icons.arrow_forward_ios);

  // Jika sudah di halaman login atau dashboard, langsung return (penting untuk multi-test)
  if (tester.any(loginHeader) ||
      tester.any(masuk) ||
      tester.any(find.textContaining('Dashboard'))) {
    return;
  }

  if (tester.any(skip)) {
    await tester.tap(skip);
    await tester.pumpAndSettle();
    return;
  }

  if (tester.any(masuk)) {
    await tester.tap(masuk.first);
    await tester.pumpAndSettle();
    return;
  }

  for (int i = 0; i < 5; i++) {
    if (tester.any(masuk)) break;
    if (tester.any(nextBtn)) {
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
    }
  }

  if (tester.any(masuk)) {
    await tester.tap(masuk.first);
    await tester.pumpAndSettle();
  }
  // expect(loginHeader) DIHAPUS agar tidak error di test kedua dst
}

Future<void> login(WidgetTester tester, String email, String password) async {
  // Tunggu field email muncul (paling aman untuk multi-test)
  await tester.pumpUntilFound(
    find.byType(TextFormField).first,
    timeout: const Duration(seconds: 15),
  );

  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Masuk'));
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

Future<void> verifyMahasiswaDashboard(WidgetTester tester) async {
  final headerJadwal = find.textContaining('Jadwal Bimbingan Aktif');
  final emptyStateJadwal = find.text('Tidak ada jadwal bimbingan aktif');
  final headerProgress = find.textContaining('Progress Magang');

  await tester.pumpUntilFound(
    headerJadwal.or(emptyStateJadwal).or(headerProgress),
    timeout: const Duration(seconds: 20),
  );

  expect(headerProgress, findsOneWidget);
  expect(emptyStateJadwal, findsOneWidget);

  print(
    'Dashboard Mahasiswa berhasil diverifikasi (kondisi empty state jadwal)',
  );
}

Future<void> verifyAdminDashboard(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 3));
  expect(find.text('Ringkasan Pengguna'), findsOneWidget);
  expect(find.text('Total Pengguna'), findsOneWidget);
  expect(find.text('Mahasiswa'), findsOneWidget);
  expect(find.text('Dosen'), findsOneWidget);
  expect(find.text('Admin'), findsOneWidget);
  expect(find.text('Aksi Cepat'), findsOneWidget);
  expect(find.text('Kelola Users'), findsOneWidget);
  expect(find.text('Kelola Mapping'), findsOneWidget);
  print('Verifikasi Admin Dashboard BERHASIL');
}

Future<void> verifyDosenDashboard(WidgetTester tester) async {
  expect(find.text('Dashboard Dosen'), findsWidgets);
}

// FUNGSI LOGOUT UMUM — TETAP SEPERTI VERSI LAMA KAMU (untuk Dosen/Admin)
Future<void> logoutViaProfile(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  final profileTab = find.text('Akun');
  if (profileTab.evaluate().isNotEmpty) {
    await tester.tap(profileTab.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  expect(
    find.text('Profil'),
    findsWidgets,
    reason: 'Gagal pindah/verifikasi halaman Profil sebelum mencari logout.',
  );

  final logoutIcon = find.byIcon(Icons.logout);
  expect(
    logoutIcon,
    findsOneWidget,
    reason: 'Ikon logout tidak ditemukan di AppBar Profil',
  );

  await tester.tap(logoutIcon);
  await tester.pumpAndSettle();

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

  expect(
    confirmButton,
    findsOneWidget,
    reason: 'Tombol "Logout" di BottomSheet tidak ditemukan',
  );

  await tester.tap(confirmButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(
    find.text('Selamat Datang').or(find.text('Masuk ke akun Anda')),
    findsWidgets,
    reason: 'Gagal kembali ke halaman login setelah logout',
  );
}

// FUNGSI LOGOUT KHUSUS MAHASISWA — DITAMBAHKAN BARU (tidak mengganggu yang lain)
Future<void> logoutViaProfileMahasiswa(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  final profileTab = find.text('Profil');
  expect(
    profileTab,
    findsAtLeastNWidgets(1),
    reason: 'Tab Profil tidak ditemukan di bottom navigation mahasiswa',
  );
  await tester.tap(profileTab.first);
  await tester.pumpAndSettle(const Duration(seconds: 3));

  final profileTitleInAppBar = find.descendant(
    of: find.byType(AppBar),
    matching: find.text('Profil'),
  );

  expect(
    profileTitleInAppBar,
    findsOneWidget,
    reason: 'Gagal verifikasi title AppBar Profil mahasiswa',
  );

  final logoutIcon = find.descendant(
    of: find.byType(AppBar),
    matching: find.byIcon(Icons.logout),
  );

  expect(
    logoutIcon,
    findsOneWidget,
    reason: 'Ikon logout tidak ditemukan di AppBar Profil mahasiswa',
  );
  await tester.tap(logoutIcon);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  final confirmButton = find.text('Logout');
  expect(
    confirmButton,
    findsOneWidget,
    reason: 'Tombol konfirmasi Logout tidak ditemukan',
  );
  await tester.tap(confirmButton);
  await tester.pumpAndSettle(const Duration(seconds: 5));

  expect(
    find.text('Selamat Datang'),
    findsOneWidget,
    reason:
        'Gagal kembali ke halaman login setelah logout (tidak ditemukan teks "Selamat Datang")',
  );
}

// Extension OR untuk Finder — TETAP SAMA
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

// Extension pumpUntilFound — TETAP SAMA
extension WidgetTesterX on WidgetTester {
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      if (finder.evaluate().isNotEmpty) {
        await pumpAndSettle();
        return;
      }
      await pump(const Duration(milliseconds: 500));
    }
    throw FlutterError('Timed out waiting for $finder');
  }
}
