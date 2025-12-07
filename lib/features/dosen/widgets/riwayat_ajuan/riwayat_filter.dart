import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_riwayat_viewmodel.dart';

class RiwayatFilter extends StatelessWidget {
  const RiwayatFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenRiwayatAjuanViewModel>(
      builder: (context, vm, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Bubble: SEMUA
              _buildFilterChip(
                context, 
                label: 'Semua', 
                isSelected: vm.activeFilter == null,
                onSelected: () => vm.setFilter(null),
              ),
              
              const SizedBox(width: 8),

              // Bubble: DISETUJUI
              _buildFilterChip(
                context, 
                label: 'Disetujui', 
                isSelected: vm.activeFilter == AjuanStatus.disetujui,
                color: Colors.green,
                onSelected: () => vm.setFilter(AjuanStatus.disetujui),
              ),

              const SizedBox(width: 8),

              // Bubble: DITOLAK
              _buildFilterChip(
                context, 
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

  Widget _buildFilterChip(
    BuildContext context, {
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
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: color,
      backgroundColor: Colors.grey[200],
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}