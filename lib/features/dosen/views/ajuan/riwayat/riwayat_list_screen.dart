import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/riwayat_ajuan_viewmodel.dart'; 
import 'package:ebimbingan/features/dosen/widgets/riwayat_ajuan/riwayat_list.dart';
import 'package:ebimbingan/features/dosen/widgets/riwayat_ajuan/riwayat_filter.dart';
import 'package:ebimbingan/features/dosen/widgets/riwayat_ajuan/riwayat_header.dart';

class DosenRiwayatAjuan extends StatefulWidget {
  final String mahasiswaUid;

  const DosenRiwayatAjuan({
    super.key,
    required this.mahasiswaUid,
  });

  @override
  State<DosenRiwayatAjuan> createState() => _DosenRiwayatAjuanState();
}

class _DosenRiwayatAjuanState extends State<DosenRiwayatAjuan> {
  @override
  void initState() {
    super.initState();
    // Memanggil fungsi load data spesifik mahasiswa saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DosenRiwayatAjuanViewModel>()
          .pilihMahasiswa(widget.mahasiswaUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomUniversalAppbar(
        judul: "Detail Riwayat Ajuan",
      ),
      body: Consumer<DosenRiwayatAjuanViewModel>(
        builder: (context, vm, child) {
          final m = vm.selectedMahasiswa;

          return Column(
            children: [
              // 1. Header Mahasiswa
              if (m != null)
                RiwayatHeader(
                  name: m.name,
                  placement: m.placement ?? '-',
                )
              else
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),

              // Filter Bubble
              RiwayatFilter(),
              
              SizedBox(height: 8),
              
              // 2. List Riwayat
              Expanded(
                child: RiwayatList(mahasiswaUid: widget.mahasiswaUid)
              ),
            ],
          );
        },
      ),
    );
  }
}