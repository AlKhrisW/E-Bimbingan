import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notifikasi_viewmodel.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_button_back.dart';

class CustomNotificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: const CustomBackButton(),
      title: const Text(
        "Notifikasi",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,
        ),
      ),
      actions: [
        Consumer<NotificationViewModel>(
          builder: (context, vm, _) => IconButton(
            icon: const Icon(Icons.done_all, color: AppTheme.primaryColor),
            tooltip: "Tandai semua dibaca",
            onPressed: () {
              vm.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Semua ditandai terbaca")),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}