// lib/features/admin/widgets/mapping/mahasiswa_mapping_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/models/user_model.dart';
import '../../../../core/themes/app_theme.dart';
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
    final viewModel = Provider.of<DetailMappingViewModel>(context, listen: false);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Relasi Bimbingan'),
          content: Text(
            'Yakin ingin menghapus ${mahasiswa.name} dari bimbingan ${dosen.name}?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
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
      final success = await viewModel.removeMapping(mahasiswa.uid, dosen.uid);
      if (!context.mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.successMessage ?? 'Berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        onRefresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Gagal menghapus'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
              child: Icon(
                Icons.school,
                color: AppTheme.secondaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Info mahasiswa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mahasiswa.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${mahasiswa.nim ?? 'N/A'} • ${mahasiswa.programStudi ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // TOMBOL HAPUS — INI YANG DIPERBAIKI
            ElevatedButton(
              onPressed: () => _confirmRemove(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(80, 38), // INI YANG MENYELAMATKAN
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}