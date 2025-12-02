import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_ajuan_bimbingan_viewmodel.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:intl/intl.dart';

class DosenAjuanDetail extends StatelessWidget {
  final AjuanBimbinganModel ajuan;
  const DosenAjuanDetail({super.key, required this.ajuan});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DosenAjuanBimbinganViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Detail Ajuan")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: FutureBuilder<UserModel>(
          future: vm.getMahasiswa(ajuan.mahasiswaUid),
          builder: (ctx, snap) {
            final nama = snap.data?.name ?? "Memuat...";
            final nim = snap.data?.nim ?? "";

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mahasiswa", style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text("$nama ($nim)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text("Topik"), Text(ajuan.judulTopik, style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text("Tanggal"), Text(DateFormat('dd MMMM yyyy').format(ajuan.tanggalBimbingan)),
                Text("Jam"), Text(ajuan.waktuBimbingan),
                Text("Metode"), Text(ajuan.metodeBimbingan),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      icon: Icon(Icons.check), label: Text("Setujui"),
                      onPressed: () async {
                        await vm.setujui(ajuan.ajuanUid);
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      icon: Icon(Icons.close), label: Text("Tolak"),
                      onPressed: () => _showTolakDialog(context, vm, ajuan.ajuanUid),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showTolakDialog(BuildContext ctx, DosenAjuanBimbinganViewModel vm, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text("Tolak Ajuan"),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: "Alasan penolakan")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal")),
          ElevatedButton(
            onPressed: () {
              vm.tolak(uid, controller.text);
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            child: Text("Tolak"),
          ),
        ],
      ),
    );
  }
}