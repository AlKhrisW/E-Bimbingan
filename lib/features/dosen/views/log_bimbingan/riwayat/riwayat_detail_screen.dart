import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/data/models/wrapper/helper_log_bimbingan.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

class DosenRiwayatBimbinganDetail extends StatelessWidget {
  final HelperLogBimbingan data; 

  const DosenRiwayatBimbinganDetail({
    super.key,
    required this.data, 
  });

  @override
  Widget build(BuildContext context) {

    final tanggalPengajuan = DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID')
        .format(data.log.waktuPengajuan);
    final tanggalBimbingan = DateFormat('dd MMMM yyyy', 'id_ID')
        .format(data.ajuan.tanggalBimbingan);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(judul: "Detail Log Bimbingan"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildField(label: "Nama", value: data.mahasiswa.name),
            BuildField(label: "Tempat Penempatan", value: data.mahasiswa.placement ?? "-"),
            BuildField(label: "Topik Kegiatan", value: data.ajuan.judulTopik),
            BuildField(label: "Tanggal Bimbingan", value: tanggalBimbingan),
            BuildField(label: "Waktu Bimbingan", value: data.ajuan.waktuBimbingan),
            BuildField(label: "Metode Bimbingan", value: data.ajuan.metodeBimbingan),            
            BuildField(label: "Ringkasan Hasil Bimbingan", value: data.log.ringkasanHasil),
            BuildField(label: "Tanggal Penulisan", value: tanggalPengajuan),
            
            if (data.log.lampiranUrl != null && data.log.lampiranUrl!.isNotEmpty)
              BuildField(label: "Lampiran", value: data.log.lampiranUrl!),

            BuildField(label: "Status", value: data.log.status.toString()),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }
}