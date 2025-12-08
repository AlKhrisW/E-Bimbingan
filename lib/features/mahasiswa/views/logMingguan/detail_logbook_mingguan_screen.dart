import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Themes & Widgets
import 'package:ebimbingan/core/themes/app_theme.dart';
import '../../widgets/log_mingguan/mingguan_status_badge.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/custom_image_preview.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

// Models
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_mingguan.dart';

class DetailLogbookMingguanScreen extends StatelessWidget {
  final MahasiswaMingguanHelper? data;

  const DetailLogbookMingguanScreen({
    super.key,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return _buildMainContent(context, data!);
    }

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is MahasiswaMingguanHelper) {
      return _buildMainContent(context, args);
    }

    return Scaffold(
      appBar: CustomUniversalAppbar(judul: "Detail Logbook"),
      body: const Center(
        child: Text("Data logbook tidak ditemukan"),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, MahasiswaMingguanHelper helper) {
    final log = helper.log;
    final ajuan = helper.ajuan;
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
            StatusBadgeWidget(status: log.status),
            
            const SizedBox(height: 20),

            // --- DATA UTAMA ---
            BuildField(label: "Topik Bimbingan", value: ajuan.judulTopik),
            BuildField(label: "Jadwal Bimbingan", value: formatDate),
            BuildField(label: "Metode Bimbingan", value: ajuan.metodeBimbingan),
            
            // --- RINGKASAN HASIL ---
            BuildField(label: "Ringkasan Hasil", value: log.ringkasanHasil),

            const SizedBox(height: 10),

            // --- BUKTI KEHADIRAN ---
            const Text(
              "Bukti Kehadiran",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            
            // Menggunakan Widget Baru
            ImagePreviewWidget(base64Image: log.lampiranUrl),
            
            const SizedBox(height: 20),

            // --- CATATAN DOSEN ---
            if (log.catatanDosen != null && log.catatanDosen!.isNotEmpty) ...[
              const Text(
                "Catatan Dosen",
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        log.catatanDosen!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}