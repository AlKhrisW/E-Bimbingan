// lib/features/dosen/modals/riwayat_modal.dart
import 'package:ebimbingan/core/utils/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/widgets/custom_modal_menu.dart';
import '../views/log_bimbingan/dosen_riwayat_logbook_screen.dart';
import '../views/ajuan/dosen_riwayat_ajuan_screen.dart';

class RiwayatModal {
  static void show() {
    showModalBottomSheet(
      context: appNavigatorKey.currentContext!,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RiwayatModalContent(),
    );
  }
}

// Widget utama modal (bisa diprivate dengan _)
class _RiwayatModalContent extends StatelessWidget {
  const _RiwayatModalContent();

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
              "Riwayat Bimbingan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Daftar menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: const [
                MenuItem(
                  title: "Riwayat Logbook",
                  iconPath: 'assets/images/icon/riwayat-ajuan.png',
                  destination: DosenRiwayatLogbook(),
                ),
                SizedBox(height: 12),
                MenuItem(
                  title: "Riwayat Ajuan",
                  iconPath: 'assets/images/icon/riwayat-ajuan.png',
                  destination: DosenRiwayatAjuan(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}