import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';

class BimbinganCard extends StatelessWidget {
  final String name;
  final String judulTopik;
  final VoidCallback onTap;
  
  const BimbinganCard({
    super.key,
    required this.name,
    required this.judulTopik,
    required this.onTap,
  });

  String get _initials {
    if (name.trim().isEmpty) return '?';
    return name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BARIS 1: AVATAR, NAMA, dan JUDUL TOPIK
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.backgroundColor,
                    child: Text(
                      _initials,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Container Nama & Judul Topik
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Mahasiswa
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Judul Topik
                          Text(
                            "Topik: $judulTopik",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // BARIS 2: TOMBOL/Indikator Detail (Align Right)
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Ketuk untuk Detail",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}