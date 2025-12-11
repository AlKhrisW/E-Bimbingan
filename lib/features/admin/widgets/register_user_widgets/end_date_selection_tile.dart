import 'package:flutter/material.dart';
import '/../../../core/themes/app_theme.dart';

class EndDateSelectionTile extends StatelessWidget {
  final DateTime? endDate;
  final TextEditingController controller; // Controller teks
  final bool isEnabled;
  final VoidCallback onTap;

  const EndDateSelectionTile({
    super.key,
    required this.endDate,
    required this.controller, // Diterima
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan warna primary untuk ikon dan border jika field enabled
    final color = isEnabled ? AppTheme.primaryColor : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller, // Menggunakan controller untuk menampilkan teks
        readOnly: true, // Tidak bisa diketik manual
        enabled: isEnabled,
        onTap: isEnabled ? onTap : null, // Memanggil date picker
        style: TextStyle(
          color: (endDate == null && isEnabled)
              ? Colors.grey.shade600
              : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: 'Tanggal Akhir Magang',
          prefixIcon: Icon(Icons.calendar_month, color: color),
          suffixIcon: Icon(Icons.arrow_drop_down, color: color),
          // Border yang konsisten
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color),
          ),
        ),
        validator: (value) {
          if (isEnabled && (value == null || value.isEmpty)) {
            return 'Tanggal wajib dipilih.';
          }
          return null;
        },
      ),
    );
  }
}
