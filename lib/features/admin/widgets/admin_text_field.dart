// lib/features/admin/widgets/admin_text_field.dart

import 'package:flutter/material.dart';

class AdminTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType type;
  final bool enabled;

  const AdminTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.type = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        keyboardType: type,
        // Validator hanya dijalankan jika field enabled
        validator: enabled
            ? (value) => (value == null || value.isEmpty)
                ? '$label wajib diisi.'
                : null
            : null,
      ),
    );
  }
}