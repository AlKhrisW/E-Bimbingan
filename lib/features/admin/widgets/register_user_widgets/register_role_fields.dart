// lib/features/admin/widgets/register_role_fields.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/user_model.dart';

import '../admin_text_field.dart';
import 'date_selection_tile.dart';
import 'dosen_dropdown_field.dart';
import 'jabatan_dropdown_field.dart';

class RegisterRoleFields extends StatelessWidget {
  final String selectedRole;
  final bool isEditMode;
  final bool isDosenListLoading;
  
  // Mahasiswa fields
  final TextEditingController nimNipController;
  final TextEditingController placementController;
  final DateTime? startDate;
  final UserModel? selectedDosen;
  final List<UserModel> dosenList;
  final void Function(DateTime?) onDateSelected;
  final void Function(UserModel?) onDosenChanged;

  // Dosen fields
  final List<String> jabatanOptions;
  final String? selectedJabatan;
  final void Function(String?) onJabatanChanged;

  const RegisterRoleFields({
    super.key,
    required this.selectedRole,
    required this.isEditMode,
    required this.isDosenListLoading,
    required this.nimNipController,
    required this.placementController,
    required this.startDate,
    required this.selectedDosen,
    required this.dosenList,
    required this.onDateSelected,
    required this.onDosenChanged,
    required this.jabatanOptions,
    required this.selectedJabatan,
    required this.onJabatanChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNimNipEnabled = !isEditMode;

    if (selectedRole == 'Mahasiswa') {
      return Column(
        children: [
          AdminTextField(
            controller: nimNipController,
            label: 'NIM',
            icon: Icons.badge,
            type: TextInputType.number,
            enabled: isNimNipEnabled,
          ),
          AdminTextField(
            controller: placementController,
            label: 'Penempatan Magang',
            icon: Icons.business,
          ),
          DateSelectionTile(
            startDate: startDate,
            isEnabled: true, // Selalu true karena sudah ada di logic Mahasiswa
            onTap: () async {
              // Kita perlu memindahkan date picker logic ke sini atau ke screen
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: startDate ?? DateTime.now(),
                firstDate: DateTime(2023, 1),
                lastDate: DateTime(2026, 12),
              );
              onDateSelected(picked);
            },
          ),
          isDosenListLoading
              ? const Center(child: LinearProgressIndicator())
              : DosenDropdownField(
                  dosenList: dosenList,
                  selectedDosen: selectedDosen,
                  onChanged: onDosenChanged,
                ),
        ],
      );
    } else if (selectedRole == 'Dosen') {
      return Column(
        children: [
          AdminTextField(
            controller: nimNipController,
            label: 'NIP',
            icon: Icons.badge,
            type: TextInputType.number,
            enabled: isNimNipEnabled,
          ),
          JabatanDropdownField(
            jabatanOptions: jabatanOptions,
            selectedJabatan: selectedJabatan,
            onChanged: onJabatanChanged,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}