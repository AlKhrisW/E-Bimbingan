// lib/core/widgets/custom_button_back.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_theme.dart';

class CustomBackButton extends StatelessWidget {
  final double size;

  const CustomBackButton({
    super.key,
    this.size = 24, // default size biar tidak error
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.only(left: 16),
      icon: Container(
        width: size + 10,
        height: size + 10,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: size * 0.7,
          ),
        ),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
    );
  }
}
