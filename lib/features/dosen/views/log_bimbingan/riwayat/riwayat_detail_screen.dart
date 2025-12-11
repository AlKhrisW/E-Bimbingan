import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/custom_image_preview.dart';
import 'package:ebimbingan/data/models/wrapper/dosen_helper_mingguan.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_riwayat_viewmodel.dart';

class DosenRiwayatBimbinganDetail extends StatelessWidget {
  // Ubah menjadi nullable agar bisa kosong saat dari notifikasi
  final HelperLogBimbingan? data; 

  const DosenRiwayatBimbinganDetail({
    super.key,
    this.data, // Tidak lagi required
  });

  @override
  Widget build(BuildContext context) {
    // Panggil ViewModel
    final vm = Provider.of<DosenRiwayatBimbinganViewModel>(context, listen: false);

    // 1. Cek Data dari Constructor (Cara Lama/Manual)
    if (data != null) {
      return _buildMainContent(data!);
    }

    // 2. Cek Data dari Arguments (Route/Notifikasi)
    final args = ModalRoute.of(context)?.settings.arguments;

    // Jika Arguments berupa Objek Helper (Navigasi manual)
    if (args is HelperLogBimbingan) {
      return _buildMainContent(args);
    }

    // Jika Arguments berupa String ID (Navigasi via Notifikasi)
    if (args is String) {
      return FutureBuilder<HelperLogBimbingan?>(
        future: vm.getLogDetail(args),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              appBar: CustomUniversalAppbar(judul: "Detail Log Bimbingan"),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              appBar: const CustomUniversalAppbar(judul: "Detail Log Bimbingan"),
              body: Center(
                child: Text(
                  "Data log tidak ditemukan.\nError: ${snapshot.error ?? ''}",
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
      appBar: CustomUniversalAppbar(judul: "Detail Log Bimbingan"),
      body: Center(child: Text("Kesalahan navigasi")),
    );
  }

  /// WIDGET TERPISAH: UI UTAMA
  Widget _buildMainContent(HelperLogBimbingan contentData) {
    // Pindahkan logika status ke sini menggunakan contentData lokal
    bool isDisetujui = contentData.log.status == LogBimbinganStatus.approved;
    bool isDitolak = contentData.log.status == LogBimbinganStatus.rejected;

    Color statusColor;
    if (isDisetujui) {
      statusColor = Colors.green;
    } else if (isDitolak) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    String statusText;
    if (isDisetujui) {
      statusText = "Disetujui";
    } else if (isDitolak) {
      statusText = "Ditolak";
    } else {
      statusText = "Proses";
    }

    final tanggalPengajuan = DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID')
        .format(contentData.log.waktuPengajuan);
    final tanggalBimbingan = DateFormat('dd MMMM yyyy', 'id_ID')
        .format(contentData.ajuan.tanggalBimbingan);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(judul: "Detail Log Bimbingan"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildField(label: "Nama", value: contentData.mahasiswa.name),
            BuildField(label: "Tempat Penempatan", value: contentData.mahasiswa.placement ?? "-"),
            BuildField(label: "Topik Kegiatan", value: contentData.ajuan.judulTopik),
            BuildField(label: "Tanggal Bimbingan", value: tanggalBimbingan),
            BuildField(label: "Waktu Bimbingan", value: contentData.ajuan.waktuBimbingan),
            BuildField(label: "Metode Bimbingan", value: contentData.ajuan.metodeBimbingan),            
            BuildField(label: "Ringkasan Hasil Bimbingan", value: contentData.log.ringkasanHasil),
            BuildField(label: "Tanggal Penulisan", value: tanggalPengajuan),
            
            const SizedBox(height: 10),

            const Text(
              "Lampiran",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6),
            
            ImagePreviewWidget(base64Image: contentData.log.lampiranUrl),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }
}