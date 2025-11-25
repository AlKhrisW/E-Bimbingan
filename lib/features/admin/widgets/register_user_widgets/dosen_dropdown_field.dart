// lib/features/admin/widgets/dosen_dropdown_field.dart

import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';

class DosenDropdownField extends StatelessWidget {
  final List<UserModel> dosenList;
  final UserModel? selectedDosen;
  final void Function(UserModel?) onChanged;

  const DosenDropdownField({
    super.key,
    required this.dosenList,
    required this.selectedDosen,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (dosenList.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Text("❌ Tidak ada data Dosen yang tersedia."),
        );
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<UserModel>(
        decoration: const InputDecoration(
          labelText: 'Dosen Pembimbing',
          prefixIcon: Icon(Icons.people),
        ),
        value: selectedDosen,
        items: dosenList.map((dosen) {
          return DropdownMenuItem(value: dosen, child: Text(dosen.name));
        }).toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null ? 'Dosen Pembimbing wajib dipilih.' : null,
      ),
    );
  }
}