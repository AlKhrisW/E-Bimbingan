import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';
// Import Helper
import 'package:ebimbingan/data/models/wrapper/helper_log_harian.dart';

class LogbookHarianDetail extends StatelessWidget {
  // Ubah menjadi Wrapper Helper & Nullable
  final HelperLogbookHarian? data;

  const LogbookHarianDetail({
    super.key,
    this.data, // Tidak required
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DosenLogbookHarianViewModel>(context, listen: false);

    // 1. Cek Data dari Constructor (Cara Lama/Manual)
    if (data != null) {
      return _buildMainContent(data!);
    }

    // 2. Cek Data dari Arguments (Route/Notifikasi)
    final args = ModalRoute.of(context)?.settings.arguments;

    // Jika Arguments berupa Objek Helper (Navigasi manual via pushNamed)
    if (args is HelperLogbookHarian) {
      return _buildMainContent(args);
    }

    // Jika Arguments berupa String ID (Navigasi via Notifikasi)
    if (args is String) {
      return FutureBuilder<HelperLogbookHarian?>(
        future: vm.getLogbookDetail(args),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              appBar: CustomUniversalAppbar(judul: "Detail Logbook Harian"),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              appBar: const CustomUniversalAppbar(judul: "Detail Logbook Harian"),
              body: Center(
                child: Text(
                  "Data logbook tidak ditemukan.\nError: ${snapshot.error ?? ''}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return _buildMainContent(snapshot.data!);
        },
      );
    }

    return const Scaffold(
      appBar: CustomUniversalAppbar(judul: "Detail Logbook Harian"),
      body: Center(child: Text("Kesalahan navigasi")),
    );
  }

  /// WIDGET TERPISAH: UI UTAMA
  /// Tidak lagi bergantung pada Consumer / vm.selectedMahasiswa, tapi pada parameter [contentData]
  Widget _buildMainContent(HelperLogbookHarian contentData) {
    final logbook = contentData.logbook;
    final mahasiswa = contentData.mahasiswa;

    final dateFormatted = DateFormat('dd MMMM yyyy', 'id_ID').format(logbook.tanggal);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(judul: "Detail Logbook Harian"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildField(label: "Nama", value: mahasiswa.name),
            BuildField(label: "NIM", value: mahasiswa.nim ?? "-"),
            BuildField(label: "Program Studi", value: mahasiswa.programStudi ?? "-"),
            BuildField(label: "Tempat Penempatan", value: mahasiswa.placement ?? "-"),
            BuildField(label: "Tanggal Penulisan", value: dateFormatted),
            BuildField(label: "Topik Kegiatan", value: logbook.judulTopik),
            BuildField(label: "Deskripsi Kegiatan", value: logbook.deskripsi),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}