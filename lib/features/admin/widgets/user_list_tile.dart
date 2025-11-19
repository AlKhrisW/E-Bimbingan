// lib/features/admin/widgets/user_list_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../viewmodels/admin_viewmodel.dart'; 
import '../views/register_user_screen.dart'; // Untuk navigasi edit
import '../views/user_detail_screen.dart'; // Untuk navigasi detail

class UserListTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRefresh; // Callback untuk memicu refresh list setelah delete

  const UserListTile({
    super.key,
    required this.user,
    required this.onRefresh,
  });

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

  // --- LOGIC DELETE (Dipindahkan ke dalam widget ini) ---
  Future<void> _confirmAndDelete(BuildContext context) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} berhasil dihapus!'),
            backgroundColor: Colors.red.shade600, 
          ),
        );
        onRefresh(); // Memanggil callback refresh di AdminUsersScreen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      }
    }
  }

  // LOGIC NAVIGASI EDIT
  void _navigateToEditUser(BuildContext context) {
      HapticFeedback.lightImpact(); 
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RegisterUserScreen(userToEdit: user), 
        ),
      ).then((_) {
        onRefresh(); // Memanggil callback refresh setelah Edit
      });
  }
  
  // LOGIC NAVIGASI DETAIL
  void _navigateToDetail(BuildContext context) {
      HapticFeedback.lightImpact(); 
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UserDetailScreen(user: user), 
        ),
      ).then((_) {
        onRefresh(); // Memanggil callback refresh jika ada perubahan
      });
  }


  @override
  Widget build(BuildContext context) {
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
        onTap: () => _navigateToDetail(context), // Klik kartu -> Detail
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
                onPressed: () => _navigateToEditUser(context),
              ),
              // Tombol Delete (Panggil fungsi konfirmasi)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmAndDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}