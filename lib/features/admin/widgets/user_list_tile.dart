// lib/features/admin/widgets/user_list_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../views/register_user_screen.dart';
import '../views/user_detail_screen.dart';

class UserListTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRefresh;
  final VoidCallback? onDelete;

  const UserListTile({
    super.key,
    required this.user,
    required this.onRefresh,
    this.onDelete,
  });

  String _getUserSubtitle(UserModel user) {
    if (user.role.toLowerCase() == 'mahasiswa') {
      final String prodi = user.programStudi ?? 'Sistem Informasi';
      return 'Mahasiswa - $prodi';
    } else if (user.role.toLowerCase() == 'dosen') {
      return 'Dosen - ${user.jabatan ?? 'N/A'}';
    } else if (user.role.toLowerCase() == 'admin') {
      return 'Admin - Utama';
    }
    return 'Role Tidak Dikenal';
  }

  void _navigateToEditUser(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => RegisterUserScreen(userToEdit: user),
          ),
        )
        .then((_) => onRefresh());
  }

  void _navigateToDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => UserDetailScreen(user: user)),
        )
        .then((_) => onRefresh());
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _getUserSubtitle(user);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(15),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 1.5),
              color: AppTheme.primaryColor.withOpacity(0.1), // lebih sesuai primary
            ),
            child: const Icon(Icons.person_outline, color: AppTheme.primaryColor, size: 28),
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
          ),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                onPressed: () => _navigateToEditUser(context),
                tooltip: 'Edit user',
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded, // SAMA DENGAN MAPPING
                    color: AppTheme.errorColor ?? Colors.red.shade600,
                    size: 26,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Hapus user',
                ),
            ],
          ),
        ),
      ),
    );
  }
}