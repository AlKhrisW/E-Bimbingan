import 'package:flutter/material.dart';

class DosenMahasiswaProgressCard extends StatelessWidget {
  final String studentName;
  final String placement;
  final String period;
  
  // Data Progress Logbook
  final int logbookCurrent;
  final int logbookTarget;
  final double logbookPercent;

  // Data Progress Bimbingan
  final int bimbinganCurrent;
  final int bimbinganTarget;
  final double bimbinganPercent;

  const DosenMahasiswaProgressCard({
    super.key,
    required this.studentName,
    required this.placement,
    required this.period,
    required this.logbookCurrent,
    required this.logbookTarget,
    required this.logbookPercent,
    required this.bimbinganCurrent,
    required this.bimbinganTarget,
    required this.bimbinganPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER: NAMA & PLACEMENT ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      placement,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  period,
                  style: TextStyle(fontSize: 10, color: Colors.grey[800]),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),

          // --- PROGRESS BARS ---
          // Row untuk menampilkan 2 progress bersebelahan agar hemat tempat
          Row(
            children: [
              // 1. Logbook Harian
              Expanded(
                child: _buildMiniProgress(
                  label: "Log-book Harian",
                  current: logbookCurrent,
                  total: logbookTarget,
                  percent: logbookPercent,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              // 2. Log Bimbingan
              Expanded(
                child: _buildMiniProgress(
                  label: "Log-book Bimbingan",
                  current: bimbinganCurrent,
                  total: bimbinganTarget,
                  percent: bimbinganPercent,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniProgress({
    required String label,
    required int current,
    required int total,
    required double percent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            Text(
              "$current/$total",
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6, // Tipis
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}