import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';

class LogbookHarianDetail extends StatelessWidget {
  final LogbookHarianModel logbook;

  const LogbookHarianDetail({
    super.key,
    required this.logbook,
  });

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
                BuildField(label: "Nama", value: mahasiswa.name),
                BuildField(label: "NIM", value: mahasiswa.nim ?? "-"),
                BuildField(label: "Program Studi", value: mahasiswa.programStudi ?? "-"),
                BuildField(label: "Tempat Penempatan", value: mahasiswa.placement ?? "-"),

                // === Detail Logbook ===
                BuildField(label: "Tanggal Penulisan", value: dateFormatted),
                BuildField(label: "Topik Kegiatan", value: logbook.judulTopik),
                BuildField(label: "Deskripsi Kegiatan", value: logbook.deskripsi),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}