// lib/features/admin/views/admin_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/profile_page_appBar.dart';
import '../../../core/widgets/custom_profile_card.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../auth/views/login_page.dart';
import '../viewmodels/admin_profile_viewmodel.dart';

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
      final vm = context.read<AdminProfileViewModel>();
      vm.setCurrentUser(widget.user);
      vm.fetchUser(widget.user.uid);
      vm.resetMessages();
    });
  }

  // INI YANG SESUAI DENGAN ProfilePageAppbar → HARUS TERIMA BuildContext
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await context.read<AuthViewModel>().logout();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProfileViewModel>(
      builder: (context, vm, child) {
        // snackbar handler
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (vm.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(vm.errorMessage!), backgroundColor: Colors.red),
            );
            vm.resetMessages();
          }
          if (vm.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(vm.successMessage!), backgroundColor: Colors.green),
            );
            vm.resetMessages();
          }
        });

        final user = vm.currentUser ?? widget.user;

        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: ProfilePageAppbar(
            onLogout: _handleLogout, // SEKARANG SUDAH SESUAI: terima BuildContext
          ),
          body: ProfileCardWidget(
            name: user.name,
            avatarInitials: null, // otomatis ambil dari nama
            onEditPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profil admin belum tersedia')),
              );
            },
            fields: [
              _buildField('Email', user.email),
              _buildField('Role', user.roleLabel),
              _buildField('Nomor Telepon', user.phoneNumber ?? '-'),
            ],
          ),
        );
      },
    );
  }
}