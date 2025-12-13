import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Jangan lupa import provider
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/data/models/wrapper/dosen_helper_ajuan.dart';
import 'package:ebimbingan/core/widgets/status_card/ajuan_status_badge.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_riwayat_viewmodel.dart'; // Import ViewModel

class DosenAjuanRiwayatDetail extends StatelessWidget {
  // Ubah menjadi nullable
  final AjuanWithMahasiswa? data; 

  const DosenAjuanRiwayatDetail({
    super.key,
    this.data, // Tidak required
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan ViewModel yang sesuai (Riwayat)
    final vm = Provider.of<DosenRiwayatAjuanViewModel>(context, listen: false);

    // 1. Cek Data dari Constructor (Cara Lama/Manual)
    if (data != null) {
      return _buildMainContent(data!);
    }

    // 2. Cek Data dari Arguments (Route/Notifikasi)
    final args = ModalRoute.of(context)?.settings.arguments;

    // Jika Arguments berupa Objek (Navigasi manual via pushNamed dengan arguments)
    if (args is AjuanWithMahasiswa) {
      return _buildMainContent(args);
    }

    // Jika Arguments berupa String ID (Navigasi via Notifikasi)
    if (args is String) {
      return FutureBuilder<AjuanWithMahasiswa?>(
        future: vm.getAjuanDetail(args),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              appBar: CustomUniversalAppbar(judul: "Detail Riwayat"),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              appBar: const CustomUniversalAppbar(judul: "Detail Riwayat"),
              body: Center(
                child: Text("Data tidak ditemukan.\nError: ${snapshot.error ?? ''}"),
              ),
            );
          }

          return _buildMainContent(snapshot.data!);
        },
      );
    }

    return const Scaffold(
      appBar: CustomUniversalAppbar(judul: "Detail Riwayat"),
      body: Center(child: Text("Kesalahan navigasi")),
    );
  }

  /// WIDGET TERPISAH: UI UTAMA
  Widget _buildMainContent(AjuanWithMahasiswa contentData) {
    
    final tanggalPengajuan = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
        .format(contentData.ajuan.waktuDiajukan);
    final tanggalBimbingan = DateFormat('dd MMMM yyyy', 'id_ID')
        .format(contentData.ajuan.tanggalBimbingan);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(judul: "Detail Ajuan Bimbingan"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATUS BADGE ---
            StatusAjuan(status: contentData.ajuan.status),

            const SizedBox(height: 20),

            // --- DATA UTAMA ---
            BuildField(label: "Nama", value: contentData.mahasiswa.name),
            BuildField(label: "Tempat Penempatan", value: contentData.mahasiswa.placement ?? "-"),
            BuildField(label: "Topik Kegiatan", value: contentData.ajuan.judulTopik),
            BuildField(label: "Tanggal Bimbingan", value: tanggalBimbingan),
            BuildField(label: "Waktu Bimbingan", value: contentData.ajuan.waktuBimbingan),
            BuildField(label: "Metode Bimbingan", value: contentData.ajuan.metodeBimbingan),
            BuildField(label: "Tanggal Penulisan", value: tanggalPengajuan),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}