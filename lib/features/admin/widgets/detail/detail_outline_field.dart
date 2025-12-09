import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class DetailOutlineField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const DetailOutlineField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Menggunakan Padding di luar agar konsisten dengan TextFormField
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      // Kita menggunakan TextFormField yang diset readOnly untuk mendapatkan
      // styling outline, label, dan icon yang konsisten dengan form input.
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87, // Nilai data
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          // Menggunakan border yang konsisten (OutlineInputBorder)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Memastikan label selalu floating di atas
          floatingLabelBehavior: FloatingLabelBehavior.always,
          // Mengatur warna border saat tidak fokus (default adalah warna biru/primary)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.5), // Warna outline
            ),
          ),
        ),
      ),
    );
  }
}