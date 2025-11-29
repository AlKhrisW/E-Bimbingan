// lib/features/dosen/modals/bimbingan_modal.dart

import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/utils/navigation/app_navigator.dart';
import '../views/ajuan/dosen_ajuan_screen.dart';
import '../views/log_harian/dosen_progres_screen.dart';

class BimbinganModal {
  static void show(UserModel user) {
    showModalBottomSheet(
      context: appNavigatorKey.currentContext!,
      isScrollControlled: true,
      enableDrag: true,          // bisa swipe ke bawah
      isDismissible: true,       // tap area gelap → tutup
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        // Tinggi modal
        height: MediaQuery.of(appNavigatorKey.currentContext!).size.height * 0.4,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),

        child: Column(
          children: [
            // Handle kecil di atas
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
                "Menu Bimbingan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // LIST MENU
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                children: [

                  // ITEM 1
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        appNavigatorKey.currentState!
                          ..pop()
                          ..push(MaterialPageRoute(
                            builder: (_) => DosenAjuan(user: user),
                          ));
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/icon/validasi-ajuan.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(width: 16),

                            Expanded(
                              child: Text(
                                "Ajuan Bimbingan",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),

                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // ITEM 2
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        appNavigatorKey.currentState!
                          ..pop()
                          ..push(MaterialPageRoute(
                            builder: (_) => DosenProgres(),
                          ));
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/icon/laporan-progres.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(width: 16),

                            Expanded(
                              child: Text(
                                "Progres Mahasiswa",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
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