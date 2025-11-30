import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/custom_universal_back_appBar.dart';
import 'tambah_logbook_harian.dart';
import '../widgets/report_harian_item.dart';
import 'detail_logbook_harian.dart'; // <-- FIX

class MahasiswaLaporanScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaLaporanScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomUniversalAppbar(judul: "Laporan Harian"),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("logbook_harian")
            .where("mahasiswaUid", isEqualTo: user.uid)
            .orderBy("tanggal", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada laporan...",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // ========== Convert to Map List ==========
          final List<Map<String, dynamic>> laporan = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return {
              "id": doc.id,
              "tanggalRaw": data["tanggal"],
              "tanggal": formatTanggal(data["tanggal"]),
              "judulTopik": data["judulTopik"] ?? "",
              "deskripsi": data["deskripsi"] ?? "",
            };
          }).toList();

          // ========== GROUPING BY TANGGAL ==========
          Map<String, List<Map<String, dynamic>>> grouped = {};

          for (var item in laporan) {
            String tgl = item["tanggal"];
            if (!grouped.containsKey(tgl)) grouped[tgl] = [];
            grouped[tgl]!.add(item);
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===================== USER CARD =====================
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4E3FF),
                      border: Border.all(
                        color: const Color(0xFF4D7CFE),
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xFF4D7CFE),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'M',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F5FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Color(0xFF4D7CFE),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.programStudi ?? "Program Studi",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F5FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.description, size: 14, color: Color(0xFF4D7CFE)),
                                  const SizedBox(width: 4),
                                  Text(
                                    laporan.length.toString(),
                                    style: const TextStyle(
                                      color: Color(0xFF4D7CFE),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),

                // Divider
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                ),
                const SizedBox(height: 12),

                // ===================== LIST GROUPED =====================
                for (var entry in grouped.entries) ...[
                  // Header tanggal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EFFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Color(0xFF4D7CFE),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Item per tanggal
                  for (var item in entry.value) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailLogbookHarianScreen(
                              logbookHarianUid: item["id"], 
                            ),
                          ),
                        );
                      },
                      child: ReportItem(
                        icon: Icons.calendar_today,
                        title: item['judulTopik'] ?? '',
                        description: item['deskripsi'] ?? '',
                      ),
                    ),
                  ]
                ],

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahLogbookHarianScreen(user: user),
            ),
          );
        },
        backgroundColor: const Color(0xFF4D7CFE),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  // ===================== FORMAT TANGGAL =====================
  static String formatTanggal(Timestamp ts) {
    final date = ts.toDate();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final thisDate = DateTime(date.year, date.month, date.day);

    if (thisDate == today) return "Today";
    if (thisDate == today.subtract(const Duration(days: 1))) return "Yesterday";

    return "${date.day} ${_namaBulan(date.month)}";
  }

  static String _namaBulan(int m) {
    const bulan = [
      "",
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return bulan[m];
  }
}
