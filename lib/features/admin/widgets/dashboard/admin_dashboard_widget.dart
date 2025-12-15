// lib/features/admin/widgets/dashboard/admin_dashboard_appbar.dart

import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart'; // Sesuaikan path jika berbeda

class AdminDashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String placement;
  final String? photoUrl;

  const AdminDashboardAppBar({
    super.key,
    required this.name,
    required this.placement,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = name.isNotEmpty ? name.split(" ")[0] : "User";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "U";

    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      surfaceTintColor: AppTheme.backgroundColor,
      elevation: 0,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile section (sama persis)
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl!) : null,
                child: photoUrl == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$firstName 👋",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    placement,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // KOSONGKAN BAGIAN KANAN → tidak ada ikon notifikasi
          const SizedBox(width: 48), // spasi kosong seukuran tombol notif // atau bisa juga SizedBox(width: 48) agar layout tetap seimbang
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}