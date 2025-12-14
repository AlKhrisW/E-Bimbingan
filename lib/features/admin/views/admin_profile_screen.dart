import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';

import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../auth/views/login_page.dart';
import '../viewmodels/admin_profile_viewmodel.dart';
import '../widgets/admin_profile_page_appbar.dart';

class AdminProfileScreen extends StatefulWidget {
  final UserModel user;

  const AdminProfileScreen({
    super.key,
    required this.user,
  });

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

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await context.read<AuthViewModel>().logout();
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      final overlay = Overlay.of(context, rootOverlay: true);
      late final OverlayEntry entry;

      entry = OverlayEntry(
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
                children: const [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gagal logout. Silakan coba lagi.',
                      style: TextStyle(
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

      overlay.insert(entry);
      Future.delayed(const Duration(seconds: 3), entry.remove);
    }
  }

  Widget _buildProfileHeader(UserModel user) {
    String initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A';

    final parts = user.name.split(' ');
    if (parts.length > 1) {
      initials = parts.take(2).map((e) => e[0]).join().toUpperCase();
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
            user.name,
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
              'Administrator',
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
      builder: (context, vm, _) {
        final user = vm.currentUser ?? widget.user;

        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AdminProfilePageAppbar(
            onLogout: _handleLogout,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ExpansionTile(
                        collapsedBackgroundColor: AppTheme.primaryColor,
                        collapsedIconColor: Colors.white,
                        collapsedTextColor: Colors.white,
                        backgroundColor: Colors.white,
                        iconColor: AppTheme.primaryColor,
                        textColor: AppTheme.primaryColor,
                        collapsedShape:
                            const RoundedRectangleBorder(side: BorderSide.none),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: const Text(
                          'Detail Informasi Admin',
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
                          const BuildField(
                            label: 'Status',
                            value: 'Active',
                          ),
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
