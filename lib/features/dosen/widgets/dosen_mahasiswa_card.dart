// features/dosen/widgets/mahasiswa_card.dart
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';

class MahasiswaCard extends StatelessWidget {
  final String name;
  final String nim;
  final String? programStudi;
  final String mahasiswaUid;
  final VoidCallback onTap;

  const MahasiswaCard({
    super.key,
    required this.name,
    required this.nim,
    this.programStudi,
    required this.mahasiswaUid,
    required this.onTap,
  });

  // Generate initials dari nama
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.backgroundColor,
                  child: Text(
                    _initials,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Informasi mahasiswa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
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
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${nim} / ${programStudi ?? '-'}",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Detail indicator
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Detail",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 22,
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
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