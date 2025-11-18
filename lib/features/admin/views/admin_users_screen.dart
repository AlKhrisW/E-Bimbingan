// lib/features/admin/views/admin_users_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Untuk Haptic Feedback
import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../viewmodels/admin_viewmodel.dart'; 
// Import screen Registrasi User
import 'register_user_screen.dart'; 

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

  // Helper untuk mendapatkan detail subtitle
  String _getUserSubtitle(UserModel user) {
    if (user.role == 'mahasiswa') {
      final String prodi = user.programStudi ?? 'Sistem Informasi'; 
      return 'Mahasiswa - $prodi';
    } else if (user.role == 'dosen') {
      return 'Dosen - ${user.jabatan ?? 'N/A'}';
    } else if (user.role == 'admin') {
      return 'Admin - Utama';
    }
    return 'Role Tidak Dikenal';
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
  
  // FUNGSI NAVIGASI KE REGISTER USER
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

  // --- LOGIC BARU: KONFIRMASI DELETE ---
  Future<void> _confirmAndDelete(BuildContext context, UserModel user) async {
    HapticFeedback.lightImpact();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Pengguna'),
          content: Text('Anda yakin ingin menghapus akun ${user.name} (${user.role}) secara permanen?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final viewModel = Provider.of<AdminViewModel>(context, listen: false);
      final success = await viewModel.deleteUser(user.uid);
      
      if (success) {
        // Tampilkan notifikasi modern setelah berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} berhasil dihapus!'),
            backgroundColor: Colors.red.shade600, // Warna merah sesuai permintaan
          ),
        );
        // Refresh list
        setState(() {
          _usersFuture = _loadUsers();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      }
    }
  }


  // Widget untuk menampilkan data User dalam ListTile (styling sama)
  Widget _buildUserListTile(BuildContext context, UserModel user) {
    final subtitle = _getUserSubtitle(user);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4, 
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), 
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact(); 
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detail ${user.name}')));
          // TODO: Navigasi ke Edit User
        },
        borderRadius: BorderRadius.circular(15),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
          tileColor: Colors.grey.shade50, 
          
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 1.5),
              color: Colors.blue.shade50.withOpacity(0.3) 
            ),
            child: const Icon(Icons.person_outline, color: AppTheme.primaryColor, size: 28),
          ),
          
          title: Text(
            user.name, 
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor 
            )
          ),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Edit
              IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menuju halaman Edit User...')));
                },
              ),
              // Tombol Delete (Panggil fungsi konfirmasi)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmAndDelete(context, user), // Panggil method delete
              ),
            ],
          ),
        ),
      ),
    );
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
                    return _buildUserListTile(context, user);
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