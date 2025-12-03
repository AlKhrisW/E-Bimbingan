// lib/features/admin/views/admin_users_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../viewmodels/admin_user_management_viewmodel.dart';
import '../widgets/user_list_tile.dart';
import 'register_user_screen.dart';

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
  int _prevRoleIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = Provider.of<AdminUserManagementViewModel>(context, listen: false);
      vm.loadAllUsers();
      vm.resetMessages();
    });
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildRoleFilterButton(String role) {
    final isActive = _selectedRole == role;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          final newIndex = _roles.indexOf(role);
          setState(() {
            if (isActive) {
              _selectedRole = '';
            } else {
              _selectedRole = role;
              _prevRoleIndex = newIndex;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Text(
            role,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRegisterUser(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => const RegisterUserScreen()),
        )
        .then((_) {
      Provider.of<AdminUserManagementViewModel>(context, listen: false).loadAllUsers();
    });
  }

  // FIXED: Hanya pakai user.uid (tidak ada user.id)
  Future<void> _deleteUser(UserModel user) async {
    if (user.uid == null || user.uid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID tidak valid')),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final confirmed = await ConfirmDeleteDialog.show(
      context: context,
      itemName: user.name,
      customMessage: "Akun ${user.role} ini akan dihapus permanen beserta semua datanya.",
      onConfirmed: () async {
        final vm = Provider.of<AdminUserManagementViewModel>(context, listen: false);
        return await vm.deleteUser(user.uid!); // PASTI pakai uid
      },
    );

    if (confirmed == true && mounted) {
      Provider.of<AdminUserManagementViewModel>(context, listen: false).loadAllUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminUserManagementViewModel>(context);
    final query = _searchController.text.toLowerCase();
    final targetRole = _selectedRole.toLowerCase();

    final filteredUsers = vm.users.where((user) {
      final roleMatch = _selectedRole.isEmpty ||
          user.role.toLowerCase().contains(targetRole);
      final queryMatch = user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.nim ?? '').toLowerCase().contains(query);
      return roleMatch && queryMatch;
    }).toList();

    int currentIndex = _selectedRole.isEmpty ? 0 : _roles.indexOf(_selectedRole);
    bool slideFromRight = currentIndex >= _prevRoleIndex;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Users',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama, email, atau NIM...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                filled: true,
                fillColor: Colors.grey.shade50,
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
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
          ),

          // FILTER ROLE
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _roles.map(_buildRoleFilterButton).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // LIST USER
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? Center(child: Text('Error: ${vm.errorMessage!}'))
                    : filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              _selectedRole.isEmpty
                                  ? 'Tidak ada pengguna ditemukan.'
                                  : 'Tidak ada pengguna $_selectedRole ditemukan.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              final offsetAnimation = Tween<Offset>(
                                begin: Offset(slideFromRight ? 1.0 : -1.0, 0),
                                end: Offset.zero,
                              ).animate(animation);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                            child: ListView.builder(
                              key: ValueKey('filter:$_selectedRole-query:$query'),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return UserListTile(
                                  user: user,
                                  onRefresh: () => vm.loadAllUsers(),
                                  onDelete: () => _deleteUser(user),
                                );
                              },
                            ),
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