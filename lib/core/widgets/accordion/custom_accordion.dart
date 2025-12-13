import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart'; // Sesuaikan path

class AccordionWrapper extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ExpansibleController? controller;

  const AccordionWrapper({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ExpansionTile(
            controller: controller,
            // Style Tertutup
            collapsedBackgroundColor: AppTheme.primaryColor,
            collapsedIconColor: Colors.white,
            collapsedTextColor: Colors.white,
            
            // Style Terbuka
            backgroundColor: Colors.white,
            iconColor: AppTheme.primaryColor,
            textColor: AppTheme.primaryColor,
            
            // Border
            collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppTheme.primaryColor, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),

            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            initiallyExpanded: initiallyExpanded,
            childrenPadding: const EdgeInsets.all(15),
            children: children,
          ),
        ),
      ),
    );
  }
}