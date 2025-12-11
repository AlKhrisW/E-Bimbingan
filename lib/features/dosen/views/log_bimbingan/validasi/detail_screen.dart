import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/custom_image_preview.dart';
import 'package:ebimbingan/data/models/wrapper/dosen_helper_mingguan.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_tolak_dialog.dart';
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_viewmodel.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

class DosenLogbookDetail extends StatelessWidget {
  // Ubah menjadi nullable
  final HelperLogBimbingan? data; 

  const DosenLogbookDetail({
    super.key,
    this.data, // Tidak required
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DosenBimbinganViewModel>(context, listen: false);

    // 1. Cek Data dari Constructor (Cara Lama/Manual)
    if (data != null) {
      return _buildMainContent(context, vm, data!);
    }

    // 2. Cek Data dari Arguments (Route/Notifikasi)
    final args = ModalRoute.of(context)?.settings.arguments;

    // Jika Arguments berupa Objek Helper (Navigasi manual)
    if (args is HelperLogBimbingan) {
      return _buildMainContent(context, vm, args);
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

          return _buildMainContent(context, vm, snapshot.data!);
        },
      );
    }

    return const Scaffold(
      appBar: CustomUniversalAppbar(judul: "Detail Log Bimbingan"),
      body: Center(child: Text("Kesalahan navigasi")),
    );
  }

  /// WIDGET TERPISAH: UI UTAMA
  Widget _buildMainContent(BuildContext context, DosenBimbinganViewModel vm, HelperLogBimbingan contentData) {
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
            BuildField(label: "Tanggal Penulisan", value: tanggalPengajuan),
            BuildField(label: "Ringkasan Hasil Bimbingan", value: contentData.log.ringkasanHasil),
            
            const Text(
              "Lampiran / Bukti",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 6),

            ImagePreviewWidget(base64Image: contentData.log.lampiranUrl),

            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              // TOMBOL VERIFIKASI
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.backgroundColor,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(
                      Colors.green.withOpacity(0.15),
                    ),
                  ),
                  icon: const Icon(Icons.check, color: Colors.green),
                  label: const Text("Verifikasi",
                      style: TextStyle(color: Colors.green)),
                  onPressed: contentData.log.status != LogBimbinganStatus.pending
                      ? null
                      : () async {
                          await vm.verifikasiLog(contentData.log.logBimbinganUid);
                          if (context.mounted) Navigator.pop(context);
                        },
                ),
              ),
              
              const SizedBox(width: 12),
              
              // TOMBOL REVISI (TOLAK)
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.backgroundColor,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(
                      Colors.orange.withOpacity(0.15),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note, color: Colors.orange),
                  label: const Text("Revisi",
                      style: TextStyle(color: Colors.orange)),
                  onPressed: contentData.log.status != LogBimbinganStatus.pending
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return TolakAjuanDialog(
                              onConfirm: (catatan) async {
                                await vm.tolakLog(contentData.log.logBimbinganUid, catatan);
                                if (context.mounted) Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}