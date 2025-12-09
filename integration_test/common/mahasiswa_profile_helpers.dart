// integration_test/common/mahasiswa_profile_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// =============================================================
/// ============ MAHASISWA PROFILE / LOGOUT HELPERS ============
/// =============================================================

/// Logout khusus MAHASISWA (fail-safe: tidak akan melempar jika elemen tidak ada)
/// Gunakan ini hanya di test mahasiswa untuk menghindari regresi pada test admin.
Future<void> logoutMahasiswaViaProfile(WidgetTester tester) async {
  // tunggu UI settle sebentar
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // 1) Coba navigasi ke tab "Profil" (label Mahasiswa)
  final profilTab = find.text('Profil');

  if (profilTab.evaluate().isEmpty) {
    // Tab Profil tidak ada — aman untuk skip (tidak mempengaruhi test utama)
    print('⚠️ [Mahasiswa] Tab "Profil" tidak ditemukan — skip logout.');
    return;
  }

  // Tap tab Profil dan tunggu
  await tester.tap(profilTab.first);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // 2) Verifikasi judul halaman Profil
  if (find.text('Profil').evaluate().isEmpty) {
    print('⚠️ [Mahasiswa] Judul "Profil" tidak terdeteksi setelah navigasi — skip logout.');
    return;
  }

  // 3) Cari ikon logout di AppBar dan tap jika ada
  final logoutIcon = find.byIcon(Icons.logout);
  if (logoutIcon.evaluate().isEmpty) {
    print('⚠️ [Mahasiswa] Ikon logout tidak ditemukan di AppBar — skip logout.');
    return;
  }

  await tester.tap(logoutIcon.first);
  await tester.pumpAndSettle();

  // 4) Cari tombol konfirmasi "Logout" pada BottomSheet/modal
  final confirmButton = find.widgetWithText(ElevatedButton, 'Logout');
  if (confirmButton.evaluate().isEmpty) {
    print('⚠️ [Mahasiswa] Tombol "Logout" pada konfirmasi tidak ditemukan — skip logout.');
    return;
  }

  await tester.tap(confirmButton.first);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // 5) Check kembali ke halaman login (safe check tanpa Finder.or)
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
