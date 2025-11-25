// lib/features/admin/views/admin_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
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

  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =====================================================
  // FIX LOGOUT — tanpa ubah file temanmu
  // Ubah menjadi Future<void> agar sesuai signature teman
  // =====================================================
  Future<void> _handleLogout(BuildContext context) async {
    if (!mounted) return;

    try {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      await authVm.logout();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('❌ Logout Error: $e');
      if (mounted) {
        _showSnackbar(context, 'Gagal logout: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProfileViewModel>(
      builder: (context, vm, child) {
        final user = vm.currentUser ?? widget.user;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (vm.errorMessage != null) {
            _showSnackbar(context, vm.errorMessage!, Colors.red);
            vm.resetMessages();
          }
          if (vm.successMessage != null) {
            _showSnackbar(context, vm.successMessage!, Colors.green);
            vm.resetMessages();
          }
        });

        return Scaffold(
          appBar: ProfilePageAppbar(
            onLogout: _handleLogout, // ✔ sekarang compatible
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: vm.isLoading
                      ? null
                      : () => _showPhotoMenu(context, vm, user),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          border: Border.all(color: Colors.blue, width: 3),
                        ),
                        child: ClipOval(child: _buildPhotoWidget(user)),
                      ),
                      if (vm.isLoading)
                        const SizedBox(
                          width: 120,
                          height: 120,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.roleLabel,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text("Email: ${user.email}"),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: vm.isLoading
                      ? null
                      : () => _handleUploadPhoto(context, vm, user.uid),
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Foto (Galeri)'),
                ),

                const SizedBox(height: 10),

                if (user.photoBase64 != null && user.photoBase64!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: vm.isLoading
                        ? null
                        : () => _handleRemovePhoto(context, vm, user.uid),
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoWidget(UserModel user) {
    if (user.photoBase64 != null && user.photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(user.photoBase64!);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        );
      } catch (_) {
        return _buildDefaultAvatar();
      }
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return const Center(
      child: Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }

  void _showPhotoMenu(
    BuildContext context,
    AdminProfileViewModel vm,
    UserModel user,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Foto Profil',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pilih dari Galeri'),
            onTap: vm.isLoading
                ? null
                : () {
                    Navigator.pop(context);
                    _handleUploadPhoto(context, vm, user.uid);
                  },
          ),
          if (user.photoBase64 != null && user.photoBase64!.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Foto'),
              onTap: vm.isLoading
                  ? null
                  : () {
                      Navigator.pop(context);
                      _handleRemovePhoto(context, vm, user.uid);
                    },
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> _handleUploadPhoto(
    BuildContext context,
    AdminProfileViewModel vm,
    String uid,
  ) async {
    await vm.updateProfilePhoto(context, uid);
  }

  Future<void> _handleRemovePhoto(
    BuildContext context,
    AdminProfileViewModel vm,
    String uid,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Foto'),
        content: const Text('Yakin ingin hapus foto profil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await vm.removeProfilePhoto(uid);
    }
  }
}
