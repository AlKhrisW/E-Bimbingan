// lib/features/admin/views/admin_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../viewmodels/admin_profile_viewmodel.dart';
import '../../../core/widgets/profile_page_appBar.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../auth/views/login_page.dart';

class AdminProfileScreen extends StatefulWidget {
  final UserModel user;
  const AdminProfileScreen({super.key, required this.user});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<AdminProfileViewModel>(context, listen: false);
      if (vm.currentUser == null) {
        vm.setCurrentUser(widget.user);
      }
      vm.fetchUser(widget.user.uid);
      vm.resetMessages();
    });
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Sekarang fungsi ini MENERIMA BuildContext sesuai dengan ProfilePageAppbar
  Future<void> _handleLogout(BuildContext context) async {
    if (!mounted) return;

    try {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      await authVm.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      _showSnackbar('Gagal logout: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProfileViewModel>(
      builder: (context, vm, child) {
        final user = vm.currentUser ?? widget.user;

        // Tampilkan pesan error/success sekali saja
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (vm.errorMessage != null) {
            _showSnackbar(vm.errorMessage!, Colors.red);
            vm.resetMessages();
          }
          if (vm.successMessage != null) {
            _showSnackbar(vm.successMessage!, Colors.green);
            vm.resetMessages();
          }
        });

        return Scaffold(
          appBar: ProfilePageAppbar(
            // Sekarang langsung passing fungsi yang sudah sesuai tipe
            onLogout: _handleLogout,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halaman Profil Admin",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text("Nama: ${user.name}"),
                Text("Email: ${user.email}"),
                Text("Role: ${user.roleLabel}"),
                const SizedBox(height: 20),
                const Text("Pengaturan dan informasi administrator."),
              ],
            ),
          ),
        );
      },
    );
  }
}