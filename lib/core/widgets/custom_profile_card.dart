// profile_card_widget.dart (VERSI FINAL – BISA SCROLL, AVATAR & NAMA FIXED)

import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';

class ProfileCardWidget extends StatelessWidget {
  final String name;
  final List<Widget> fields;
  final VoidCallback onEditPressed;
  final String? avatarInitials;

  const ProfileCardWidget({
    super.key,
    required this.name,
    required this.fields,
    required this.onEditPressed,
    this.avatarInitials,
  });

  String get _initials {
    if (avatarInitials != null) return avatarInitials!;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts.last[0]).toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: AppTheme.backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 90, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor, width: 3),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  ...fields,
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppTheme.primaryColor, width: 3),
                  right: BorderSide(color: AppTheme.primaryColor, width: 3),
                  left: BorderSide(color: AppTheme.primaryColor, width: 3),
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      _initials,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nama
                  Text(
                    name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Tombol Edit
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onEditPressed,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}