import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String nip;
  final String jabatan;
  final String phoneNumber;
  final VoidCallback onEditPressed;

  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.nip,
    required this.jabatan,
    required this.phoneNumber,
    required this.onEditPressed,
  });

  String get initials {
    if (name.isEmpty) return 'D';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
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
            child: Column(
              children: [
                const SizedBox(height: 70),

                Text(
                  name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                _buildField('Email', email),
                _buildField('NIP/NIDN', nip),
                _buildField('Jabatan Fungsional', jabatan),
                _buildField('Nomor Telepon', phoneNumber),
              ],
            ),
          ),

          // Avatar
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                ),
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