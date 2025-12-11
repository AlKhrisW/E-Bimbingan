import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import Provider

// Themes & Widgets
import 'package:ebimbingan/core/themes/app_theme.dart';
import '../../widgets/log_mingguan/mingguan_status_badge.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/custom_image_preview.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

// Models
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_mingguan.dart';

// ViewModels
import 'package:ebimbingan/features/mahasiswa/viewmodels/log_mingguan_viewmodel.dart'; // Pastikan import VM

class DetailLogMingguanScreen extends StatelessWidget {
  final MahasiswaMingguanHelper? data;

  const DetailLogMingguanScreen({
    super.key,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Panggil ViewModel
    final vm = Provider.of<MahasiswaLogMingguanViewModel>(context, listen: false);

    // 1. Cek Data dari Constructor
    if (data != null) {
      return _buildMainContent(context, data!);
    }

    // 2. Cek Data dari Arguments
    final args = ModalRoute.of(context)?.settings.arguments;

    // A. Jika args berupa Object Helper (Navigasi manual)
    if (args is MahasiswaMingguanHelper) {
      return _buildMainContent(context, args);
    }

    // B. Jika args berupa String ID (Dari Notifikasi / Deep Link)
    if (args is String) {
      return FutureBuilder<MahasiswaMingguanHelper?>(
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

    // 3. Fallback
    return Scaffold(
      appBar: const CustomUniversalAppbar(judul: "Detail Logbook"),
      body: const Center(
        child: Text("Data logbook tidak ditemukan"),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, MahasiswaMingguanHelper helper) {
    final log = helper.log;
    final ajuan = helper.ajuan;
    final dosen = helper.dosen;
    final formatDate = DateFormat('dd MMMM yyyy', 'id_ID').format(ajuan.tanggalBimbingan);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomUniversalAppbar(judul: ajuan.judulTopik),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATUS BADGE ---
            MahasiswaMingguanStatus(status: log.status),
            
            const SizedBox(height: 20),

            // Info Dosen
            BuildField(label: "Dosen Pembimbing", value: dosen.name),

            // Info Ajuan
            BuildField(label: "Topik Bimbingan", value: ajuan.judulTopik),
            BuildField(label: "Jadwal Bimbingan", value: formatDate),
            BuildField(label: "Metode Bimbingan", value: ajuan.metodeBimbingan),

            // Info Log Mingguan
            BuildField(label: "Ringkasan Hasil", value: log.ringkasanHasil),

            const SizedBox(height: 10),

            // Bukti Kehadiran
            const Text(
              "Bukti Kehadiran",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            
            // Menggunakan Widget Preview Gambar
            ImagePreviewWidget(base64Image: log.lampiranUrl),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}