// TODO Implement this library.
// lib/features/admin/widgets/date_selection_tile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/../../../core/themes/app_theme.dart';

class DateSelectionTile extends StatelessWidget {
  final DateTime? startDate;
  final bool isEnabled;
  final VoidCallback onTap;

  const DateSelectionTile({
    super.key,
    required this.startDate,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.calendar_month,
          color: isEnabled ? AppTheme.primaryColor : Colors.grey,
        ),
        title: Text(
          'Tanggal Mulai Magang: ${startDate == null ? "Pilih Tanggal" : DateFormat('dd MMMM yyyy').format(startDate!)}',
          style: TextStyle(
            color: isEnabled ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isEnabled ? Colors.black87 : Colors.grey,
        ),
        onTap: isEnabled ? onTap : null,
      ),
    );
  }
}