// lib/features/admin/widgets/jabatan_dropdown_field.dart
import 'package:flutter/material.dart';
import '/../core/themes/app_theme.dart';

class JabatanDropdownField extends StatelessWidget {
  final List<String> jabatanOptions;
  final String? selectedJabatan;
  final void Function(String?) onChanged;

  const JabatanDropdownField({
    super.key,
    required this.jabatanOptions,
    required this.selectedJabatan,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jabatan Fungsional',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedJabatan,
          items: jabatanOptions.map((jabatan) {
            return DropdownMenuItem(value: jabatan, child: Text(jabatan));
          }).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Jabatan wajib dipilih.' : null,
          decoration: InputDecoration(
            hintText: 'Pilih jabatan',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            prefixIcon: const Icon(Icons.work, color: Colors.black87),
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
          isExpanded: true,
        ),
      ],
    );
  }
}