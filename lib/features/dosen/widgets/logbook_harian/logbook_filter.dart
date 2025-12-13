import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';

class LogbookFilter extends StatelessWidget {
  const LogbookFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenLogbookHarianViewModel>(
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

              // Bubble: TERVAlIDASI
              _buildFilterChip(
                label: 'Tervalidasi', 
                isSelected: vm.activeFilter == LogbookStatus.verified,
                color: Colors.green,
                onSelected: () => vm.setFilter(LogbookStatus.verified),
              ),

              const SizedBox(width: 8),

              // Bubble: PENDING
              _buildFilterChip(
                label: 'Pending', 
                isSelected: vm.activeFilter == LogbookStatus.draft,
                color: Colors.orange,
                onSelected: () => vm.setFilter(LogbookStatus.draft),
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