// features/dosen/views/logbook_harian/logbook_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';

class LogbookHarianDetail extends StatelessWidget {
  final LogbookHarianModel logbook;

  const LogbookHarianDetail({
    super.key,
    required this.logbook,
  });

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor),
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
    return Consumer<DosenLogbookHarianViewModel>(
      builder: (context, vm, child) {
        final mahasiswa = vm.selectedMahasiswa;

        if (mahasiswa == null) {
          return const Scaffold(
            body: Center(child: Text("Data mahasiswa tidak ditemukan")),
          );
        }

        final dateFormatted = DateFormat('dd MMMM yyyy', 'id_ID').format(logbook.tanggal);

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: const CustomUniversalAppbar(judul: "Detail Logbook Harian"),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Identitas Mahasiswa ===
                _buildField("Nama", mahasiswa.name),
                _buildField("NIM", mahasiswa.nim ?? "-"),
                _buildField("Program Studi", mahasiswa.programStudi ?? "-"),
                _buildField("Tempat Penempatan", mahasiswa.placement ?? "-"),

                // === Detail Logbook ===
                _buildField("Tanggal Penulisan", dateFormatted),
                _buildField("Topik Kegiatan", logbook.judulTopik),
                _buildField("Deskripsi Kegiatan", logbook.deskripsi),
              ],
            ),
          ),
        );
      },
    );
  }
}