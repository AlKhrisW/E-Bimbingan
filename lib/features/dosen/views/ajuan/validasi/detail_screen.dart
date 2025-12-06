import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_tolak_dialog.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_bimbingan_viewmodel.dart';

class DosenAjuanDetail extends StatelessWidget {
  final AjuanWithMahasiswa ajuan; 

  const DosenAjuanDetail({
    super.key,
    required this.ajuan, 
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DosenAjuanBimbinganViewModel>(context, listen: false);

    final tanggalPengajuan = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
        .format(ajuan.waktuDiajukan);
    final tanggalBimbingan = DateFormat('dd MMMM yyyy', 'id_ID')
        .format(ajuan.tanggalBimbingan);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(judul: "Detail Ajuan Bimbingan"),

      // ================== BODY (SCROLLABLE) ==================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildField(label: "Nama", value: ajuan.namaMahasiswa),
            BuildField(label: "Tempat Penempatan", value: ajuan.placement),
            BuildField(label: "Topik Kegiatan", value: ajuan.judulTopik),
            BuildField(label: "Tanggal Bimbingan", value: tanggalBimbingan),
            BuildField(label: "Waktu Bimbingan", value: ajuan.waktuBimbingan),
            BuildField(label: "Metode Bimbingan", value: ajuan.metodeBimbingan),
            BuildField(label: "Tanggal Penulisan", value: tanggalPengajuan),

            const SizedBox(height: 40), // ruang agar tidak ketutup tombol
          ],
        ),
      ),

      // tombol tolak dan terima
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
                    Colors.green.withOpacity(0.15), // efek sentuhan
                  ),
                ),
                  icon: const Icon(Icons.check, color: Colors.green),
                  label: const Text("Terima",
                      style: TextStyle(color: Colors.green)),
                  onPressed: ajuan.status != AjuanStatus.proses
                      ? null
                      : () async {
                          await vm.setujui(ajuan.ajuanUid);
                          Navigator.pop(context);
                        },
                ),
              ),
              const SizedBox(width: 12),
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
                  label: const Text("Tolak",
                      style: TextStyle(color: Colors.red)),
                  onPressed: ajuan.status != AjuanStatus.proses
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return TolakAjuanDialog(
                              onConfirm: (alasan) async {
                                await vm.tolak(ajuan.ajuanUid, alasan);
                                Navigator.pop(context);
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