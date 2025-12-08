import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import '../../viewmodels/log_mingguan_viewmodel.dart';

class MahasiswaLogFilter extends StatelessWidget {
  const MahasiswaLogFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MahasiswaLogMingguanViewModel>(
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

              // 2. DRAFT (Perlu Dilengkapi)
              _buildChip(
                label: 'Draft',
                isSelected: vm.activeFilter == LogBimbinganStatus.draft,
                color: Colors.grey[700]!,
                onSelected: () => vm.setFilter(LogBimbinganStatus.draft),
              ),
              const SizedBox(width: 8),

              // 3. PENDING (Menunggu)
              _buildChip(
                label: 'Menunggu',
                isSelected: vm.activeFilter == LogBimbinganStatus.pending,
                color: Colors.orange,
                onSelected: () => vm.setFilter(LogBimbinganStatus.pending),
              ),
              const SizedBox(width: 8),

              // 4. REJECTED (Revisi)
              _buildChip(
                label: 'Revisi',
                isSelected: vm.activeFilter == LogBimbinganStatus.rejected,
                color: Colors.red,
                onSelected: () => vm.setFilter(LogBimbinganStatus.rejected),
              ),
              const SizedBox(width: 8),

              // 5. APPROVED (Disetujui)
              _buildChip(
                label: 'Disetujui',
                isSelected: vm.activeFilter == LogBimbinganStatus.approved,
                color: Colors.green,
                onSelected: () => vm.setFilter(LogBimbinganStatus.approved),
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