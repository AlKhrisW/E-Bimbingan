import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import '../../viewmodels/log_harian_viewmodel.dart';

class MahasiswaLogHarianFilter extends StatelessWidget {
  const MahasiswaLogHarianFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MahasiswaLogHarianViewModel>(
      builder: (context, vm, _) {
        // Kita butuh getter/setter filter di ViewModel dulu.
        // Asumsi di ViewModel ada properti 'activeFilter' dan method 'setFilter'
        // Jika belum ada, nanti kita tambahkan di ViewModel (Lihat langkah 5).
        
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

              // 2. PENDING (Draft)
              _buildChip(
                label: 'Pending',
                isSelected: vm.activeFilter == LogbookStatus.draft,
                color: Colors.orange,
                onSelected: () => vm.setFilter(LogbookStatus.draft),
              ),
              const SizedBox(width: 8),

              // 3. TERVALIDASI (Verified)
              _buildChip(
                label: 'Tervalidasi',
                isSelected: vm.activeFilter == LogbookStatus.verified,
                color: Colors.green,
                onSelected: () => vm.setFilter(LogbookStatus.verified),
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