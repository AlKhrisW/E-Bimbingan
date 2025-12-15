// lib/features/admin/widgets/mapping/dosen_mapping_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../data/models/user_model.dart';
import '../../../../core/themes/app_theme.dart';
import '../../views/mapping/detail_mapping_screen.dart';

class DosenMappingCard extends StatelessWidget {
  final UserModel dosen;

  const DosenMappingCard({
    super.key,
    required this.dosen,
  });

  void _navigateToDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailMappingScreen(dosen: dosen),
      ),
    );
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
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppTheme.primaryColor,
                size: 30,
              ),
            ),
            title: Row(
              children: [
                Text(
                  dosen.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.5,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                // Badge kecil untuk kesan "mapping" tanpa angka
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.supervisor_account_rounded,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Dosen • ${dosen.jabatan ?? 'Tidak ada jabatan'}',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.primaryColor,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}