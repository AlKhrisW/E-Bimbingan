import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/data/models/wrapper/helper_log_bimbingan.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_tolak_dialog.dart';
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_viewmodel.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

class DosenLogbookDetail extends StatelessWidget {
  final HelperLogBimbingan data; 

  const DosenLogbookDetail({
    super.key,
    required this.data, 
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DosenBimbinganViewModel>(context, listen: false);

    final tanggalPengajuan = DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID')
        .format(data.log.waktuPengajuan);
    final tanggalBimbingan = DateFormat('dd MMMM yyyy', 'id_ID')
        .format(data.ajuan.tanggalBimbingan);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(judul: "Detail Log Bimbingan"),

      // ================== BODY (SCROLLABLE) ==================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Mahasiswa & Ajuan
            BuildField(label: "Nama", value: data.mahasiswa.name),
            BuildField(label: "Tempat Penempatan", value: data.mahasiswa.placement ?? "-"),
            BuildField(label: "Topik Kegiatan", value: data.ajuan.judulTopik),
            BuildField(label: "Tanggal Bimbingan", value: tanggalBimbingan),
            BuildField(label: "Waktu Bimbingan", value: data.ajuan.waktuBimbingan),
            BuildField(label: "Metode Bimbingan", value: data.ajuan.metodeBimbingan),            
            BuildField(label: "Tanggal Penulisan", value: tanggalPengajuan),
            BuildField(label: "Ringkasan Hasil Bimbingan", value: data.log.ringkasanHasil),
            
            // Jika ada lampiran (Opsional)
            if (data.log.lampiranUrl != null && data.log.lampiranUrl!.isNotEmpty)
              BuildField(label: "Lampiran", value: data.log.lampiranUrl!),

            const SizedBox(height: 40), 
          ],
        ),
      ),

      // ================== BOTTOM BUTTONS ==================
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
                  onPressed: data.log.status != LogBimbinganStatus.pending
                      ? null
                      : () async {
                          await vm.verifikasiLog(data.log.logBimbinganUid);
                          if (context.mounted) Navigator.pop(context);
                        },
                ),
              ),
              
              const SizedBox(width: 12),
              
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
                  onPressed: data.log.status != LogBimbinganStatus.pending
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return TolakAjuanDialog(
                              onConfirm: (catatan) async {
                                await vm.tolakLog(data.log.logBimbinganUid, catatan);
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