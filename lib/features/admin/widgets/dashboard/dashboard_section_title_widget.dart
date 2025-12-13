import 'package:flutter/material.dart';

class DashboardSectionTitleWidget extends StatelessWidget {
  final String title;

  const DashboardSectionTitleWidget(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}