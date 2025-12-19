// integration_test/dosen/dosen_approve_ajuan_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebimbingan/main.dart' as app;

import '../common/test_helpers.dart';
import '../common/dosen_ajuan_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String emailDosen = 'e2ed@gmail.com'; // Email dosen test kamu
  const String passwordDosen = 'password';

  const String topikAjuan = 'E2E Test - Konsultasi Bab 4 Metodologi';

  group('E2E Test - Dosen Approve Ajuan Bimbingan', () {
    setUp(() async {
      try {
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        // ignored
      }
    });

    testWidgets(
      'Dosen berhasil melihat ajuan masuk, approve, dan ajuan berubah status',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        await closeOnboarding(tester);
        await login(tester, emailDosen, passwordDosen);
        await tester.pumpAndSettle(const Duration(seconds: 10));

        await verifyDosenDashboard(tester);

        await DosenAjuanHelpers.bukaHalamanAjuanMasuk(tester);

        await DosenAjuanHelpers.bukaDetailAjuan(tester, topikAjuan);

        await DosenAjuanHelpers.approveAjuan(tester);

        await DosenAjuanHelpers.verifikasiAjuanHilang(tester, topikAjuan);

        await DosenAjuanHelpers.verifikasiDiRiwayat(tester, topikAjuan);

        await logoutViaProfile(tester);
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}
