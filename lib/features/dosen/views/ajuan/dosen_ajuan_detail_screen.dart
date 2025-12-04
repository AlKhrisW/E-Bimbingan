// dosen_ajuan_detail_screen.dart (DIKOREKSI)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_ajuan_bimbingan_viewmodel.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:intl/intl.dart';

class DosenAjuanDetail extends StatelessWidget {
  final AjuanWithMahasiswa ajuanData; 

  const DosenAjuanDetail({
    super.key,
    required this.ajuanData, 
  });

  void _showTolakDialog(BuildContext ctx, DosenAjuanBimbinganViewModel vm, String ajuanUid) {
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Tolak Ajuan"),
        content: TextField(
          controller: controller, 
          decoration: const InputDecoration(hintText: "Alasan penolakan"),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              vm.tolak(ajuanUid, controller.text);
              Navigator.pop(ctx); // Tutup dialog
              Navigator.pop(ctx); // Tutup halaman detail
            },
            child: const Text("Tolak"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DosenAjuanBimbinganViewModel>(context, listen: false);
    final AjuanBimbinganModel ajuan = ajuanData.ajuan;
    final UserModel mahasiswa = ajuanData.mahasiswa;

    // Pastikan properti tanggalBimbingan dan waktuBimbingan sudah benar
    final formattedTanggal = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(ajuan.waktuDiajukan);
    final formattedJam = DateFormat('HH:mm').format(ajuan.waktuDiajukan);

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Ajuan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detail Mahasiswa
            const Text("Mahasiswa", style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text("${mahasiswa.name} (${mahasiswa.nim})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Detail Ajuan
            const Text("Topik Bimbingan", style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(ajuan.judulTopik, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),

            const Text("Waktu Bimbingan", style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text("$formattedTanggal, Pukul $formattedJam", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            
            const Text("Metode Bimbingan", style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(ajuan.metodeBimbingan, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),

            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    icon: const Icon(Icons.check, color: Colors.white), 
                    label: const Text("Setujui", style: TextStyle(color: Colors.white)),
                    onPressed: ajuan.status != AjuanStatus.proses ? null : () async {
                      await vm.setujui(ajuan.ajuanUid); // Gunakan ajuan.ajuanUid
                      Navigator.pop(context); // Tutup halaman detail
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    icon: const Icon(Icons.close, color: Colors.white), 
                    label: const Text("Tolak", style: TextStyle(color: Colors.white)),
                    onPressed: ajuan.status != AjuanStatus.proses ? null : () => _showTolakDialog(context, vm, ajuan.ajuanUid), // Gunakan ajuan.ajuanUid
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}