// lib/core/widgets/custom_button_back.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_theme.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.only(left: 16),
      icon: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.chevron_left, 
            color: Colors.white, 
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