import 'package:flutter/material.dart';
import '../../../../../../data/models/user_model.dart';
import '../../../../core/themes/app_theme.dart';

class MahasiswaSelectionTile extends StatelessWidget {
  final UserModel mahasiswa;
  final bool isSelected;
  final VoidCallback onTap;

  const MahasiswaSelectionTile({
    super.key,
    required this.mahasiswa,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.3)
                : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
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
                    '${mahasiswa.nim ?? 'N/A'} • ${mahasiswa.programStudi ?? 'Tidak ada prodi'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Indikator pilihan
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}