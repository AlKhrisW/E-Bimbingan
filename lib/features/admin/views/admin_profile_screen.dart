import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/appbar/profile_page_appbar.dart';
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

  // Fungsi Logout
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

  // Widget Header Minimalis
  Widget _buildProfileHeader(UserModel data) {
    String initials = data.name.isNotEmpty ? data.name[0].toUpperCase() : 'A';
    if (data.name.split(' ').length > 1) {
      initials = data.name.split(' ').map((e) => e[0]).take(2).join('').toUpperCase();
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
          backgroundColor: Colors.white, // Background bersih
          appBar: ProfilePageAppbar(
            onLogout: _handleLogout,
          ),
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
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
                        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: AppTheme.primaryColor, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        title: const Text(
                          "Detail Informasi Admin",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        initiallyExpanded: true,
                        
                        childrenPadding: const EdgeInsets.all(20),
                        children: [
                          BuildField(label: 'Email', value: user.email),
                          BuildField(label: 'Nomor Telepon', value: user.phoneNumber ?? '-'),
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