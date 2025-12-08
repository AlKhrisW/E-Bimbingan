// integration_test/common/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// =============================================================
/// ================ ONBOARDING NAVIGATION HELPER ===============
/// =============================================================
Future<void> closeOnboarding(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final skip = find.text('SKIP');
  final masuk = find.text('Masuk');
  final loginHeader = find.text('Selamat Datang');
  final nextBtn = find.byIcon(Icons.arrow_forward_ios);

  if (tester.any(loginHeader)) return;
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
  for (int i = 0; i < 3; i++) {
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
  expect(
    loginHeader,
    findsOneWidget,
    reason: 'Gagal menuju login setelah onboarding.',
  );
}

/// =============================================================
/// ======================== LOGIN HELPER ========================
/// =============================================================
Future<void> login(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Masuk'));
  await tester.pumpAndSettle();
}

/// =============================================================
/// ===================== DASHBOARD VERIFY =======================
/// =============================================================
Future<void> verifyAdminDashboard(WidgetTester tester) async {
  expect(find.text('Users'), findsWidgets);
  expect(find.text('Jumlah User'), findsOneWidget);
  expect(find.text('Jumlah Mahasiswa'), findsOneWidget);
  expect(find.text('Jumlah Dosen'), findsOneWidget);
  expect(find.text('Jumlah Admin'), findsOneWidget);
  expect(find.text('Status Kegiatan'), findsWidgets);
}

Future<void> verifyDosenDashboard(WidgetTester tester) async {
  expect(find.text('Dashboard Dosen'), findsWidgets);
}

Future<void> verifyMahasiswaDashboard(WidgetTester tester) async {
  expect(find.text('Jadwal Bimbingan'), findsWidgets);
  expect(find.text('Laporan Bimbingan Magang'), findsWidgets);
  expect(find.text('Aktivitas Bimbingan'), findsWidgets);
}

/// =============================================================
/// =========================== LOGOUT ===========================
/// =============================================================
Future<void> logoutViaProfile(WidgetTester tester) async {
  // 1. Navigasi ke tab Akun/Profile
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  final profileTab = find.text('Akun');

  // TAP TAB AKUN
  if (profileTab.evaluate().isNotEmpty) {
    print('Navigasi ke tab Akun...');
    await tester.tap(profileTab.first);
    await tester.pumpAndSettle(const Duration(seconds: 2)); // Tunggu navigasi
  } else {
    print('⚠️ Tab Akun tidak ditemukan, mencoba melanjutkan.');
  }

  // VALIDASI: Pastikan kita berada di halaman Profil (judul AppBar)
  expect(
    find.text('Profil'),
    findsWidgets,
    reason: 'Gagal pindah/verifikasi halaman Profil sebelum mencari logout.',
  );

  // 2. Cari dan tap ikon logout
  // Menggunakan find.byIcon(Icons.logout)
  final logoutIcon = find.byIcon(Icons.logout);

  expect(
    logoutIcon,
    findsOneWidget,
    reason:
        'Ikon logout tidak ditemukan di AppBar Profil (Pastikan ikon dimuat di AppBar MahasiswaProfilScreen)',
  );

  await tester.tap(logoutIcon);
  await tester.pumpAndSettle(); // Tunggu BottomSheet muncul

  // 3. Tap tombol "Logout" di BottomSheet
  // Mencari tombol ElevatedButton dengan teks 'Logout'
  final confirmButton = find.widgetWithText(ElevatedButton, 'Logout');

  expect(
    confirmButton,
    findsOneWidget,
    reason: 'Tombol "Logout" di BottomSheet tidak ditemukan',
  );

  await tester.tap(confirmButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // 4. Pastikan sudah kembali ke halaman login
  expect(
    find.text('Selamat Datang').or(find.text('Masuk ke akun Anda')),
    findsWidgets,
    reason: 'Gagal kembali ke halaman login setelah logout',
  );

  print('Logout berhasil!');
}

/// =============================================================
/// ===================== FINDER EXTENSIONS ======================
/// =============================================================
extension FinderX on Finder {
  Finder or(Finder other) {
    return _OrFinder(this, other);
  }
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
