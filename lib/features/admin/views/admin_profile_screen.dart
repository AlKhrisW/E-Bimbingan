import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
// ❌ HAPUS INI:
// import '../../../core/widgets/appbar/profile_page_appbar.dart';

// ✅ GANTI DENGAN INI:
import '../widgets/admin_profile_page_appbar.dart';

import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
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

  // Fungsi Logout - DIPERBAIKI: Langsung logout tanpa modal (modal sudah di AppBar)
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Proses logout
      await context.read<AuthViewModel>().logout();
      if (!mounted) return;

      // PENTING: Gunakan root navigator untuk clear semua stack
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      // Tampilkan error menggunakan root overlay
      final overlay = Overlay.of(context, rootOverlay: true);
      OverlayEntry? errorEntry;

      errorEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gagal logout: $e',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      overlay.insert(errorEntry);

      // Auto dismiss setelah 3 detik
      Future.delayed(const Duration(seconds: 3), () {
        errorEntry?.remove();
      });
    }
  }

  // Widget Header Minimalis
  Widget _buildProfileHeader(UserModel data) {
    String initials = data.name.isNotEmpty ? data.name[0].toUpperCase() : 'A';
    if (data.name.split(' ').length > 1) {
      initials = data.name
          .split(' ')
          .map((e) => e[0])
          .take(2)
          .join('')
          .toUpperCase();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Text(
              "Administrator",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
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
        final user = vm.currentUser ?? widget.user;

        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          // ✅ GUNAKAN APPBAR KHUSUS ADMIN
          appBar: AdminProfilePageAppbar(onLogout: _handleLogout),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 1. Header Identitas
                _buildProfileHeader(user),

                const SizedBox(height: 20),

                // 2. Accordion Data Diri
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ExpansionTile(
                        // Style saat tertutup (Collapsed)
                        collapsedBackgroundColor: AppTheme.primaryColor,
                        collapsedIconColor: Colors.white,
                        collapsedTextColor: Colors.white,

                        // Style saat terbuka (Expanded)
                        backgroundColor: Colors.white,
                        iconColor: AppTheme.primaryColor,
                        textColor: AppTheme.primaryColor,

                        // Bentuk Border Rounded
                        collapsedShape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        title: const Text(
                          "Detail Informasi Admin",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        initiallyExpanded: true,

                        childrenPadding: const EdgeInsets.all(20),
                        children: [
                          BuildField(label: 'Email', value: user.email),
                          BuildField(
                            label: 'Nomor Telepon',
                            value: user.phoneNumber ?? '-',
                          ),
                          BuildField(label: 'Status', value: 'Active'),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}
