import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class MenuItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final Widget destination;

  const MenuItem({
    super.key,
    required this.title,
    required this.iconPath,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context)
            ..pop()
            ..push(MaterialPageRoute(builder: (_) => destination));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Image.asset(
                iconPath,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.description,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}