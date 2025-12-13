import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import Provider

// Themes & Widgets Universal
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/status_card/harian_status_badge.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

// Models
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_harian.dart';

// ViewModels
import 'package:ebimbingan/features/mahasiswa/viewmodels/log_harian_viewmodel.dart'; // Pastikan import VM

class MahasiswaDetailLogHarianScreen extends StatelessWidget {
  final MahasiswaHarianHelper? dataHelper;

  const MahasiswaDetailLogHarianScreen({
    super.key,
    this.dataHelper,
  });

  @override
  Widget build(BuildContext context) {
    // Panggil ViewModel
    final vm = Provider.of<MahasiswaLogHarianViewModel>(context, listen: false);

    // 1. Cek jika data dikirim langsung via Constructor
    if (dataHelper != null) {
      return _buildMainContent(context, dataHelper!);
    }

    // 2. Cek args dari Navigator
    final args = ModalRoute.of(context)?.settings.arguments;

    // A. Jika args sudah berupa Object Helper (Navigasi manual)
    if (args is MahasiswaHarianHelper) {
      return _buildMainContent(context, args);
    }

    // B. Jika args berupa String ID (Dari Notifikasi / Deep Link)
    if (args is String) {
      return FutureBuilder<MahasiswaHarianHelper?>(
        future: vm.getLogbookDetail(args),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              appBar: CustomUniversalAppbar(judul: "Detail Logbook"),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              appBar: const CustomUniversalAppbar(judul: "Detail Logbook"),
              body: Center(
                child: Text("Data tidak ditemukan.\nError: ${snapshot.error ?? ''}"),
              ),
            );
          }

          return _buildMainContent(context, snapshot.data!);
        },
      );
    }

    // 3. Fallback jika data tidak ditemukan
    return Scaffold(
      appBar: const CustomUniversalAppbar(judul: "Detail Logbook"),
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
      appBar: const CustomUniversalAppbar(
        judul: "Detail Logbook Harian", 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATUS BADGE ---
            HarianStatus(status: log.status),
            
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