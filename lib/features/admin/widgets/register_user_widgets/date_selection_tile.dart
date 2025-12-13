// lib/features/admin/widgets/register_user_widgets/date_selection_tile.dart
import 'package:flutter/material.dart';
import '/../core/themes/app_theme.dart';

class DateSelectionTile extends StatelessWidget {
  final DateTime? startDate;
  final TextEditingController controller;
  final bool isEnabled;
  final VoidCallback onTap;

  const DateSelectionTile({
    super.key,
    required this.startDate,
    required this.controller,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Mulai Magang',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: isEnabled,
          onTap: isEnabled ? onTap : null,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Pilih tanggal mulai',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            prefixIcon: const Icon(Icons.calendar_month, color: Colors.black87),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (isEnabled && (value == null || value.isEmpty)) {
              return 'Tanggal wajib dipilih.';
            }
            return null;
          },
        ),
      ],
    );
  }
}