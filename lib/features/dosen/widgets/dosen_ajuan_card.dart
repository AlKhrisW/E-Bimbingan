import 'package:flutter/material.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_ajuan_bimbingan_viewmodel.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';

class AjuanCard extends StatelessWidget {
  final AjuanBimbinganModel ajuan;
  final DosenAjuanBimbinganViewModel viewModel;
  final VoidCallback onTap;

  const AjuanCard({required this.ajuan, required this.viewModel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(ajuan.judulTopik),
        subtitle: FutureBuilder<UserModel>(
          future: viewModel.getMahasiswa(ajuan.mahasiswaUid),
          builder: (ctx, snap) => Text(snap.data?.name ?? "Memuat..."),
        ),
        trailing: ajuan.status == AjuanStatus.proses
            ? Chip(label: Text("Menunggu"), backgroundColor: Colors.orange[100])
            : Chip(
                label: Text(ajuan.status == AjuanStatus.disetujui ? "Disetujui" : "Ditolak"),
                backgroundColor: ajuan.status == AjuanStatus.disetujui ? Colors.green[100] : Colors.red[100],
              ),
      ),
    );
  }
}