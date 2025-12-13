import 'package:flutter/material.dart';

class MingguanProgressCard extends StatelessWidget {
  final int currentCount;
  final int totalTarget;
  final double progressPercentage;

  const MingguanProgressCard({
    super.key,
    required this.currentCount,
    required this.totalTarget,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    // Warna tema untuk Log Bimbingan (Hijau)
    const Color themeColor = Colors.green;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.people_alt_outlined, color: themeColor, size: 24),
          ),
          const SizedBox(width: 14),
          
          // Progress Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Log-book Bimbingan",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      "$currentCount / $totalTarget",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // The Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercentage,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                ),
                const SizedBox(height: 4),
                
                // Percentage text
                Text(
                  "${(progressPercentage * 100).toInt()}% Selesai",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}