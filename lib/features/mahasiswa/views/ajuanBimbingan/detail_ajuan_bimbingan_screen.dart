import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Tambahkan Provider

// Themes & Widgets Universal
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

// Widget Spesifik
import '../../widgets/ajuan_bimbingan/ajuan_status_badge.dart';

// Models
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_ajuan.dart';

// ViewModels
import 'package:ebimbingan/features/mahasiswa/viewmodels/ajuan_bimbingan_viewmodel.dart'; // Pastikan import VM

class MahasiswaDetailAjuanScreen extends StatelessWidget {
  final MahasiswaAjuanHelper? dataHelper;

  const MahasiswaDetailAjuanScreen({
    super.key,
    this.dataHelper,
  });

  @override
  Widget build(BuildContext context) {
    // Panggil ViewModel via Provider
    final vm = Provider.of<MahasiswaAjuanBimbinganViewModel>(context, listen: false);

    // 1. Cek jika data dikirim langsung via Constructor
    if (dataHelper != null) {
      return _buildMainContent(context, dataHelper!);
    }

    // 2. Cek args dari Navigator
    final args = ModalRoute.of(context)?.settings.arguments;

    // A. Jika args sudah berupa Object Helper (Navigasi manual)
    if (args is MahasiswaAjuanHelper) {
      return _buildMainContent(context, args);
    }

    // B. Jika args berupa String ID (Dari Notifikasi / Deep Link)
    if (args is String) {
      return FutureBuilder<MahasiswaAjuanHelper?>(
        future: vm.getAjuanDetail(args),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              appBar: CustomUniversalAppbar(judul: "Detail Ajuan"),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              appBar: const CustomUniversalAppbar(judul: "Detail Ajuan"),
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
      appBar: const CustomUniversalAppbar(judul: "Detail Ajuan"),
      body: const Center(
        child: Text("Data ajuan tidak ditemukan"),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, MahasiswaAjuanHelper helper) {
    final ajuan = helper.ajuan;
    final dosen = helper.dosen;
    
    // Format Tanggal
    final bimbingan = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(ajuan.tanggalBimbingan);
    final diajukan = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(ajuan.waktuDiajukan);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(
        judul: "Detail Ajuan Bimbingan", 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATUS BADGE ---
            MahasiswaAjuanStatus(status: ajuan.status),
            
            const SizedBox(height: 20),

            // --- DATA UTAMA ---
            
            // Info Dosen
            BuildField(label: "Dosen Pembimbing", value: dosen.name),

            // Info Ajuan
            BuildField(label: "Topik Bimbingan", value: ajuan.judulTopik),
            
            // Info Waktu & Tanggal
            Row(
              children: [
                Expanded(
                  child: BuildField(label: "Tanggal Bimbingan", value: bimbingan),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BuildField(label: "Jam Bimbingan", value: ajuan.waktuBimbingan),
                ),
              ],
            ),

            BuildField(label: "Metode Bimbingan", value: ajuan.metodeBimbingan),

            if (ajuan.keterangan != null && ajuan.keterangan!.isNotEmpty) ...[
              const SizedBox(height: 10),
              BuildField(label: "Catatan / Keterangan", value: ajuan.keterangan!),
            ],

            BuildField(label: "Tanggal Diajukan", value: diajukan),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}