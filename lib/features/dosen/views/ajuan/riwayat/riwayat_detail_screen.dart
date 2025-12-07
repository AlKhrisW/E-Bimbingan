import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/data/models/wrapper/helper_ajuan_bimbingan.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

class DosenAjuanDetail extends StatelessWidget {
  final AjuanWithMahasiswa data; 

  const DosenAjuanDetail({
    super.key,
    required this.data, 
  });

  @override
  Widget build(BuildContext context) {
    final tanggalPengajuan = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
        .format(data.ajuan.waktuDiajukan);
    final tanggalBimbingan = DateFormat('dd MMMM yyyy', 'id_ID')
        .format(data.ajuan.tanggalBimbingan);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(judul: "Detail Ajuan Bimbingan"),

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
            BuildField(label: "Tanggal Penulisan", value: tanggalPengajuan),
            BuildField(label: "Status", value: data.ajuan.status.toString()),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}