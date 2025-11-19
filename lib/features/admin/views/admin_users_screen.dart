// lib/features/admin/views/admin_users_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; 
import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../viewmodels/admin_viewmodel.dart'; 
// Import screen Registrasi User
import 'register_user_screen.dart'; 
// import 'user_detail_screen.dart';
// FIX: Import Widget Lokal yang baru
import '../widgets/user_list_tile.dart'; 

class AdminUsersScreen extends StatefulWidget {
  final UserModel user;
  const AdminUsersScreen({super.key, required this.user});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<UserModel>> _usersFuture;
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  String _selectedRole = ''; 
  final List<String> _roles = ['Mahasiswa', 'Dosen', 'Admin'];

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat semua user, memanggil AdminViewModel
  Future<List<UserModel>> _loadUsers() async {
    final viewModel = Provider.of<AdminViewModel>(context, listen: false);
    final users = await viewModel.fetchAllUsers();
    setState(() {
      _allUsers = users;
      _filterUsers(); 
    });
    return users;
  }
  
  // Fungsi untuk memfilter list (Kini mendukung tampilan SEMUA role)
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    final String targetRole = _selectedRole.toLowerCase();

    setState(() {
      _filteredUsers = _allUsers.where((user) {
        
        final bool roleMatch = _selectedRole.isEmpty 
            ? true 
            : user.role.toLowerCase() == targetRole;
        
        final queryMatch = user.name.toLowerCase().contains(query) ||
                           user.email.toLowerCase().contains(query) ||
                           (user.nim ?? '').contains(query);
                           
        return roleMatch && queryMatch;
      }).toList();
    });
  }

  // Widget Helper: Tombol Filter Kategori (Bubble)
  Widget _buildRoleFilterButton(String role) {
    final isActive = _selectedRole == role;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), 
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          setState(() {
            if (isActive) {
              _selectedRole = ''; // Toggle OFF: kembali ke default (semua)
            } else {
              _selectedRole = role; 
            }
            _filterUsers(); 
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppTheme.primaryColor : Colors.grey.shade200,
          foregroundColor: isActive ? Colors.white : Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: Size.zero, 
        ),
        child: Text(role, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
  
  // FUNGSI NAVIGASI KE REGISTER USER (MODE CREATE)
  void _navigateToRegisterUser(BuildContext context) {
    HapticFeedback.lightImpact();
    // Navigasi ke RegisterUserScreen sebagai modal
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterUserScreen()),
    ).then((_) {
      // Refresh list setelah modal ditutup (jika ada data baru)
      setState(() {
        _usersFuture = _loadUsers();
      });
    });
  }

  // --- FUNGSI REFRESH LIST (DIPANGGIL DARI USER LIST TILE) ---
  void _refreshUserList() {
    setState(() {
      _usersFuture = _loadUsers();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Users', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(), 
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0), 
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

          // --- FILTER BUBBLE MAHASISWA, DOSEN, ADMIN ---
          Center( 
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _roles.map((role) => _buildRoleFilterButton(role)).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // --- LIST USER ---
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _allUsers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
                } else if (_filteredUsers.isEmpty) {
                  final statusText = _selectedRole.isEmpty 
                      ? 'Tidak ada pengguna ditemukan.' 
                      : 'Tidak ada pengguna ${_selectedRole} yang ditemukan.';
                  return Center(child: Text(statusText));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    // FIX: Menggunakan Widget Lokal yang baru
                    return UserListTile(
                      user: user,
                      onRefresh: _refreshUserList, // Memberikan callback untuk refresh
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Tombol Tambah User (Sesuai Desain)
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_user',
        onPressed: () => _navigateToRegisterUser(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}