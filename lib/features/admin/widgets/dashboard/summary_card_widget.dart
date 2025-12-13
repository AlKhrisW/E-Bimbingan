import 'package:flutter/material.dart';

class SummaryCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const SummaryCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14), // Kurangi dari 16 ke 14
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon avatar
              CircleAvatar(
                radius: 18, // Kurangi dari 20 ke 18
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22, // Kurangi dari 24 ke 22
                ),
              ),
              const SizedBox(height: 10), // Kurangi dari 12 ke 10
              // Value text
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Kurangi dari 4 ke 2
              // Title text
              Text(
                title,
                style: TextStyle(
                  color: iconColor.withOpacity(0.8),
                  fontSize: 13, // Kurangi dari 14 ke 13
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}