// lib/features/dosen/dosen_ajuan_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_ajuan_bimbingan_viewmodel.dart';
import 'dosen_ajuan_detail_screen.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_ajuan_card.dart';

class DosenAjuan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DosenAjuanBimbinganViewModel>(context);

    // Dapatkan list ajuan PROSES
    final ajuanProses = vm.proses; 

    if (vm.isLoading) return Scaffold(appBar: AppBar(title: Text("Ajuan Menunggu")), body: Center(child: CircularProgressIndicator()));
    
    // Cek apakah list PROSES kosong
    if (ajuanProses.isEmpty) return Scaffold(appBar: AppBar(title: Text("Ajuan Menunggu")), body: Center(child: Text("Tidak ada ajuan menunggu")));
  
    return Scaffold(
      // Gunakan jumlah ajuan PROSES
      appBar: AppBar(title: Text("Ajuan Menunggu (${ajuanProses.length})")),
      body: ListView.builder(
        // Gunakan list ajuan PROSES
        itemCount: ajuanProses.length,
        itemBuilder: (ctx, i) => AjuanCard(
          // Ambil data dari list ajuan PROSES
          ajuan: ajuanProses[i],
          viewModel: vm,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DosenAjuanDetail(ajuan: ajuanProses[i])),
          ),
        ),
      ),
    );
  }
}