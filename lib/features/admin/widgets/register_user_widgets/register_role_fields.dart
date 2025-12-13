// lib/features/admin/widgets/register_user_widgets/register_role_fields.dart
import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';
import '../admin_text_field.dart';
import 'date_selection_tile.dart';
import 'end_date_selection_tile.dart';
import 'dosen_dropdown_field.dart';
import 'jabatan_dropdown_field.dart';

class RegisterRoleFields extends StatelessWidget {
  final String selectedRole;
  final bool isEditMode;
  final bool isDosenListLoading;
  // Mahasiswa fields
  final TextEditingController nimNipController;
  final TextEditingController placementController;
  final TextEditingController
  startDateTextController; // Controller teks tanggal
  final DateTime? startDate;
  final TextEditingController endDateTextController;
  final DateTime? endDate;
  final UserModel? selectedDosen;
  final List<UserModel> dosenList;
  final void Function(DateTime?) onDateSelected;
  final void Function(DateTime?) onEndDateSelected;
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
    required this.startDateTextController, // Diterima
    required this.endDateTextController,
    required this.startDate,
    required this.endDate,
    required this.selectedDosen,
    required this.dosenList,
    required this.onDateSelected,
    required this.onEndDateSelected,
    required this.onDosenChanged,
    required this.jabatanOptions,
    required this.selectedJabatan,
    required this.onJabatanChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedRole == 'Mahasiswa') {
      return Column(
        children: [
          AdminTextField(
            controller: placementController,
            label: 'Penempatan Magang',
            icon: Icons.business,
          ),
          const SizedBox(height: 16),
          DateSelectionTile(
            startDate: startDate,
            controller: startDateTextController,
            isEnabled: true,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: startDate ?? DateTime.now(),
                firstDate: DateTime(2023, 1),
                lastDate: DateTime(2026, 12),
              );
              onDateSelected(picked);
            },
          ),
          const SizedBox(height: 16),
          EndDateSelectionTile(
            endDate: endDate,
            controller: endDateTextController,
            isEnabled: true,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: endDate ?? DateTime.now(),
                firstDate: startDate ?? DateTime.now(),
                lastDate: DateTime(2026, 12),
              );
              onEndDateSelected(picked);
            },
          ),
          const SizedBox(height: 16),
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
      return JabatanDropdownField(
        jabatanOptions: jabatanOptions,
        selectedJabatan: selectedJabatan,
        onChanged: onJabatanChanged,
      );
    }
    return const SizedBox.shrink();
  }
}
