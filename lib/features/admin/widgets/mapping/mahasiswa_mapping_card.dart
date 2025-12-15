// lib/features/admin/widgets/mapping/mahasiswa_mapping_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../../data/models/user_model.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../../core/widgets/confirm_delete_dialog.dart'; // Import dialog universal
import '../../viewmodels/mapping/detail_mapping_vm.dart';

class MahasiswaMappingCard extends StatelessWidget {
  final UserModel mahasiswa;
  final UserModel dosen;
  final VoidCallback onRefresh;

  const MahasiswaMappingCard({
    super.key,
    required this.mahasiswa,
    required this.dosen,
    required this.onRefresh,
  });

  Future<void> _confirmRemove(BuildContext context) async {
    final viewModel = Provider.of<DetailMappingViewModel>(
      context,
      listen: false,
    );

    final confirmed = await ConfirmDeleteDialog.show(
      context: context,
      itemName: mahasiswa.name,
      customMessage:
          'Mahasiswa ini akan dihapus dari bimbingan ${dosen.name}. Relasi bimbingan akan hilang permanen.',
      onConfirmed: () async {
        return await viewModel.removeMapping(mahasiswa.uid, dosen.uid);
      },
    );

    // Jika user mengonfirmasi hapus
    if (confirmed == true && context.mounted) {
      // SnackBar (success/error) sudah otomatis ditampilkan oleh ConfirmDeleteDialog
      // Kita cukup refresh list
      onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 2),
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.school_rounded, // icon toga
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
          title: Text(
            mahasiswa.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.5,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${mahasiswa.nim ?? 'N/A'} • ${mahasiswa.programStudi ?? 'Tidak ada prodi'}',
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.errorColor ?? Colors.red.shade600,
              size: 26,
            ),
            onPressed: () => _confirmRemove(context),
            tooltip: 'Hapus dari bimbingan',
          ),
        ),
      ),
    );
  }
}