import 'package:flutter/material.dart';
import '../../auth/views/login_page.dart';

class MahasiswaViewModel extends ChangeNotifier {
  // Logic logout (hapus token dll)
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Handle logout + navigate ke login
  Future<void> handleLogout(BuildContext context) async {
    await logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}
