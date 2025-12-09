import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Themes & Widgets Universal
import 'package:ebimbingan/core/themes/app_theme.dart';
import '../../widgets/log_harian/harian_status_badge.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

// Models
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_harian.dart';

class MahasiswaDetailLogHarianScreen extends StatelessWidget {
  final MahasiswaHarianHelper? dataHelper;

  const MahasiswaDetailLogHarianScreen({
    super.key,
    this.dataHelper,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Cek jika data dikirim langsung via Constructor
    if (dataHelper != null) {
      return _buildMainContent(context, dataHelper!);
    }

    // 2. Cek jika data dikirim via Route Arguments
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is MahasiswaHarianHelper) {
      return _buildMainContent(context, args);
    }

    // 3. Fallback jika data tidak ditemukan
    return Scaffold(
      appBar: CustomUniversalAppbar(judul: "Detail Logbook"),
      body: const Center(
        child: Text("Data logbook tidak ditemukan"),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, MahasiswaHarianHelper helper) {
    final log = helper.logbook;
    final dosen = helper.dosen;
    
    // Format Tanggal: Senin, 12 Agustus 2024
    final formatDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(log.tanggal);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomUniversalAppbar(
        judul: "Detail Logbook Harian", 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATUS BADGE ---
            MahasiswaLogHarianStatus(status: log.status),
            
            const SizedBox(height: 20),

            // Info Dosen
            BuildField(label: "Dosen Pembimbing", value: dosen.name),

            // Info Logbook Harian
            BuildField(label: "Topik Kegiatan", value: log.judulTopik),
            BuildField(label: "Tanggal Kegiatan", value: formatDate),
            BuildField(label: "Deskripsi Kegiatan", value: log.deskripsi),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}