// lib/features/admin/widgets/jabatan_dropdown_field.dart

import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Jabatan Fungsional',
          prefixIcon: Icon(Icons.work),
        ),
        value: selectedJabatan,
        items: jabatanOptions.map((jabatan) {
          return DropdownMenuItem(value: jabatan, child: Text(jabatan));
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Jabatan wajib dipilih.' : null,
      ),
    );
  }
}