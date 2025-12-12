// lib/features/admin/widgets/register_user_widgets/dosen_dropdown_field.dart
import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';
import '/../core/themes/app_theme.dart';

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
    // Jika list kosong, tampilkan pesan
    if (dosenList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Text("Tidak ada data Dosen yang tersedia."),
      );
    }

    // Buat list item dropdown: opsi "Belum Ada" + list dosen asli
    final List<DropdownMenuItem<UserModel>> items = [];

    // Opsi default: Belum Ada Pembimbing
    final noneOption = UserModel(
      uid: '', // uid kosong untuk menandakan tidak ada
      name: 'Belum Ada Pembimbing',
      email: '',
      role: 'none',
    );
    items.add(
      DropdownMenuItem<UserModel>(
        value: noneOption,
        child: Text(
          'Belum Ada Pembimbing',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );

    // Tambahkan dosen asli
    items.addAll(
      dosenList.map((dosen) {
        return DropdownMenuItem<UserModel>(
          value: dosen,
          child: Text(dosen.name),
        );
      }).toList(),
    );

    // Tentukan value saat ini: jika selectedDosen null atau uid kosong, pakai noneOption
    UserModel? currentValue = selectedDosen;
    if (currentValue == null || currentValue.uid.isEmpty) {
      currentValue = noneOption;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dosen Pembimbing',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<UserModel>(
          value: currentValue,
          items: items,
          onChanged: onChanged,
          // Tidak ada validator wajib lagi (opsional)
          decoration: InputDecoration(
            hintText: 'Pilih dosen pembimbing',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            prefixIcon: const Icon(Icons.people, color: Colors.black87),
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
