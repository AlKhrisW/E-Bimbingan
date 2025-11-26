// lib/features/admin/views/admin_users_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../viewmodels/admin_user_management_viewmodel.dart';
import 'register_user_screen.dart';
import '../widgets/user_list_tile.dart';
import '../../../core/widgets/custom_button_back.dart';

class AdminUsersScreen extends StatefulWidget {
  final UserModel user;
  const AdminUsersScreen({super.key, required this.user});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = '';
  final List<String> _roles = ['Mahasiswa', 'Dosen', 'Admin'];

  @override
  void initState() {
    super.initState();
    
    // ⭐ PERBAIKAN: Gunakan Future.microtask untuk menunda pemanggilan 
    // loadAllUsers() agar terjadi setelah build pertama selesai.
    Future.microtask(() {
      final vm = Provider.of<AdminUserManagementViewModel>(
        context,
        listen: false,
      );
      vm.loadAllUsers();
      vm.resetMessages();
    });

    _searchController.addListener(() {
      setState(() {}); // Agar realtime
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // UI — FILTER ROLE BUBBLE (TIDAK BERUBAH)
  Widget _buildRoleFilterButton(String role) {
    final isActive = _selectedRole == role;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          setState(() {
            if (isActive) {
              _selectedRole = '';
            } else {
              _selectedRole = role;
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? AppTheme.primaryColor
              : Colors.grey.shade200,
          foregroundColor: isActive ? Colors.white : Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: Size.zero,
        ),
        child: Text(
          role,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // Navigasi ke register user (TIDAK BERUBAH)
  void _navigateToRegisterUser(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => const RegisterUserScreen()),
        )
        .then((_) {
          // Setelah kembali dari Register, load ulang data
          Provider.of<AdminUserManagementViewModel>(
            context,
            listen: false,
          ).loadAllUsers();
        });
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan Provider adalah AdminUserManagementViewModel
    final vm = Provider.of<AdminUserManagementViewModel>(context);

    // filtering real-time
    final query = _searchController.text.toLowerCase();
    final targetRole = _selectedRole.toLowerCase();

    // Mengambil data dari vm.users yang baru
    final filteredUsers = vm.users.where((user) {
      final roleMatch = _selectedRole.isEmpty
          ? true
          : user.role.toLowerCase() == targetRole;
      final queryMatch =
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.nim ?? '').contains(query);
      return roleMatch && queryMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Users',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ),

          // 🧑‍🏫 FILTER ROLE BUBBLE
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _roles
                    .map((role) => _buildRoleFilterButton(role))
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🧾 LIST USER BERBASIS VIEWMODEL
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? Center(child: Text('❌ Error: ${vm.errorMessage!}')) 
                    : filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              _selectedRole.isEmpty
                                  ? 'Tidak ada pengguna ditemukan.'
                                  : 'Tidak ada pengguna $_selectedRole yang ditemukan.',
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return UserListTile(
                                user: user,
                                onRefresh: () => vm.loadAllUsers(), 
                              );
                            },
                          ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'add_user',
        onPressed: () => _navigateToRegisterUser(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}