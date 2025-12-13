import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_riwayat_viewmodel.dart';

class AjuanFilter extends StatelessWidget {
  const AjuanFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenRiwayatAjuanViewModel>(
      builder: (context, vm, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Bubble: SEMUA
              _buildFilterChip(
                label: 'Semua', 
                isSelected: vm.activeFilter == null,
                onSelected: () => vm.setFilter(null),
              ),
              
              const SizedBox(width: 8),

              // Bubble: DISETUJUI
              _buildFilterChip(
                label: 'Disetujui', 
                isSelected: vm.activeFilter == AjuanStatus.disetujui,
                color: Colors.green,
                onSelected: () => vm.setFilter(AjuanStatus.disetujui),
              ),

              const SizedBox(width: 8),

              // Bubble: DITOLAK
              _buildFilterChip(
                label: 'Ditolak', 
                isSelected: vm.activeFilter == AjuanStatus.ditolak,
                color: Colors.red,
                onSelected: () => vm.setFilter(AjuanStatus.ditolak),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color color = Colors.blue, // Default color
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