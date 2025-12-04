import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../viewmodels/mahasiswa_laporan_viewmodel.dart';
import 'tambah_logbook_harian.dart';
import '../widgets/report_harian_item.dart';
import 'detail_logbook_harian.dart';

class MahasiswaLaporanScreen extends StatelessWidget {
  final UserModel user;
  final MahasiswaLaporanViewModel viewModel;

  MahasiswaLaporanScreen({
    super.key,
    required this.user,
  }) : viewModel = MahasiswaLaporanViewModel(mahasiswaUid: "");

  @override
  Widget build(BuildContext context) {
    final vm = MahasiswaLaporanViewModel(mahasiswaUid: user.uid);

    return Scaffold(
      appBar: const CustomAppbar(judul: "Laporan Harian"),
      body: StreamBuilder(
        stream: vm.laporanStream,
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

          final laporanList = vm.mapLaporan(snapshot.data!);
          final groupedLaporan = vm.groupByTanggal(laporanList);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // USER CARD
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4E3FF),
                      border: Border.all(color: const Color(0xFF4D7CFE), width: 2.5),
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
                                    laporanList.length.toString(),
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

                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 12),

                // GROUPED LIST
                for (var entry in groupedLaporan.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

                  for (var item in entry.value) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailLogbookHarianScreen(
                              logbookHarianUid: item["id"],
                              viewModel: vm,
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
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}
