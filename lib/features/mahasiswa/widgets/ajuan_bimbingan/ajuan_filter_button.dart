import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import '../../viewmodels/ajuan_bimbingan_viewmodel.dart';

class MahasiswaAjuanFilter extends StatelessWidget {
  const MahasiswaAjuanFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MahasiswaAjuanBimbinganViewModel>(
      builder: (context, vm, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 1. SEMUA
              _buildChip(
                label: 'Semua',
                isSelected: vm.activeFilter == null,
                onSelected: () => vm.setFilter(null),
              ),
              const SizedBox(width: 8),

              // 2. PENDING (Menunggu)
              _buildChip(
                label: 'Menunggu',
                isSelected: vm.activeFilter == AjuanStatus.proses,
                color: Colors.orange,
                onSelected: () => vm.setFilter(AjuanStatus.proses),
              ),
              const SizedBox(width: 8),

              // 3. REJECTED (Revisi)
              _buildChip(
                label: 'Revisi',
                isSelected: vm.activeFilter == AjuanStatus.ditolak,
                color: Colors.red,
                onSelected: () => vm.setFilter(AjuanStatus.ditolak),
              ),
              const SizedBox(width: 8),

              // 4. APPROVED (Disetujui)
              _buildChip(
                label: 'Disetujui',
                isSelected: vm.activeFilter == AjuanStatus.disetujui,
                color: Colors.green,
                onSelected: () => vm.setFilter(AjuanStatus.disetujui),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color color = Colors.blue,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: color,
      backgroundColor: Colors.grey[200],
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }
}