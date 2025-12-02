// lib/features/dosen/modals/bimbingan_modal.dart
import 'package:ebimbingan/core/utils/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import 'package:ebimbingan/core/widgets/custom_modal_menu.dart';
import '../views/ajuan/dosen_ajuan_screen.dart';
import '../views/log_harian/dosen_progres_screen.dart';

class BimbinganModal {
  static void show(UserModel user) {
    showModalBottomSheet(
      context: appNavigatorKey.currentContext!,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BimbinganModalContent(user: user),
    );
  }
}

class _BimbinganModalContent extends StatelessWidget {
  final UserModel user;

  const _BimbinganModalContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle drag
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Menu Bimbingan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Daftar menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                MenuItem(
                  title: "Ajuan Bimbingan",
                  iconPath: 'assets/images/icon/validasi-ajuan.png',
                  destination: DosenAjuan(),
                ),
                const SizedBox(height: 12),
                MenuItem(
                  title: "Progres Mahasiswa",
                  iconPath: 'assets/images/icon/laporan-progres.png',
                  destination: const DosenProgres(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}