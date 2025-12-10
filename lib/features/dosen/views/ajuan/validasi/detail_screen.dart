import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/helper_ajuan_bimbingan.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_tolak_dialog.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_viewmodel.dart';

class DosenAjuanDetail extends StatelessWidget {
  // Ubah menjadi nullable (?) agar bisa kosong saat dipanggil dari notifikasi
  final AjuanWithMahasiswa? data; 

  const DosenAjuanDetail({
    super.key,
    this.data, // Tidak lagi 'required'
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DosenAjuanViewModel>(context, listen: false);
    
    // 1. Cek Sumber Data
    // Prioritas 1: Data dari Constructor (Cara Lama)
    if (data != null) {
      return _buildMainContent(context, vm, data!);
    }

    // Prioritas 2: Data dari Arguments (Route / Notifikasi)
    final args = ModalRoute.of(context)?.settings.arguments;

    // Jika Arguments berupa Objek Data (Navigasi via pushNamed dengan arguments objek)
    if (args is AjuanWithMahasiswa) {
      return _buildMainContent(context, vm, args);
    }

    // Jika Arguments berupa String ID (Navigasi via Notifikasi)
    if (args is String) {
      return FutureBuilder<AjuanWithMahasiswa?>(
        future: vm.getAjuanDetail(args), // Memanggil fungsi fetch by ID
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              appBar: CustomUniversalAppbar(judul: "Detail Ajuan"),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Error State
          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              appBar: const CustomUniversalAppbar(judul: "Detail Ajuan"),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Data tidak ditemukan atau telah dihapus.\nError: ${snapshot.error ?? ''}",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          // Success State -> Render UI Utama
          return _buildMainContent(context, vm, snapshot.data!);
        },
      );
    }

    // Fallback jika tidak ada data sama sekali
    return const Scaffold(
      appBar: CustomUniversalAppbar(judul: "Detail Ajuan"),
      body: Center(child: Text("Terjadi kesalahan navigasi")),
    );
  }

  /// WIDGET TERPISAH: UI UTAMA
  /// Dipisahkan agar bisa dipakai ulang baik oleh data langsung maupun data hasil fetch
  Widget _buildMainContent(BuildContext context, DosenAjuanViewModel vm, AjuanWithMahasiswa contentData) {
    
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
            BuildField(label: "Nama", value: contentData.mahasiswa.name),
            BuildField(label: "Tempat Penempatan", value: contentData.mahasiswa.placement ?? "-"),
            BuildField(label: "Topik Kegiatan", value: contentData.ajuan.judulTopik),
            BuildField(label: "Tanggal Bimbingan", value: tanggalBimbingan),
            BuildField(label: "Waktu Bimbingan", value: contentData.ajuan.waktuBimbingan),
            BuildField(label: "Metode Bimbingan", value: contentData.ajuan.metodeBimbingan),
            BuildField(label: "Tanggal Penulisan", value: tanggalPengajuan),

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
              // TOMBOL TERIMA
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
                  label: const Text("Terima", style: TextStyle(color: Colors.green)),
                  onPressed: contentData.ajuan.status != AjuanStatus.proses
                      ? null
                      : () async {
                          await vm.setujui(contentData.ajuan.ajuanUid);
                          if (context.mounted) Navigator.pop(context);
                        },
                ),
              ),

              const SizedBox(width: 12),

              // TOMBOL TOLAK
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.backgroundColor,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(
                      Colors.red.withOpacity(0.15),
                    ),
                  ),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text("Tolak", style: TextStyle(color: Colors.red)),
                  onPressed: contentData.ajuan.status != AjuanStatus.proses
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return TolakAjuanDialog(
                                onConfirm: (alasan) async {
                                  await vm.tolak(contentData.ajuan.ajuanUid, alasan);
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