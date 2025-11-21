// lib/features/dosen/modals/riwayat_modal.dart

import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/utils/navigation/app_navigator.dart';
import '../views/dosen_riwayat_logbook_screen.dart';
import '../views/dosen_riwayat_ajuan_screen.dart';

class RiwayatModal {
  static void show(UserModel user) {
    showModalBottomSheet(
      context: appNavigatorKey.currentContext!,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(appNavigatorKey.currentContext!).size.height * 0.4,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),

        child: Column(
          children: [
            // Handle kecil
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Riwayat Bimbingan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                children: [

                  // ITEM 1 — Riwayat Logbook
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        appNavigatorKey.currentState!
                          ..pop()
                          ..push(MaterialPageRoute(
                            builder: (_) => DosenRiwayatLogbook(user: user),
                          ));
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/icon/riwayat-ajuan.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(width: 16),

                            Expanded(
                              child: Text(
                                "Riwayat Logbook",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // ITEM 2 — Riwayat Ajuan
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        appNavigatorKey.currentState!
                          ..pop()
                          ..push(MaterialPageRoute(
                            builder: (_) => DosenRiwayatAjuan(user: user),
                          ));
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/icon/riwayat-ajuan.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(width: 16),

                            Expanded(
                              child: Text(
                                "Riwayat Ajuan",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}