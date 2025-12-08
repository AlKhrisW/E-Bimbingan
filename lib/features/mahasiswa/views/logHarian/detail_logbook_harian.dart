import 'package:flutter/material.dart';
import '../../viewmodels/mahasiswa_laporan_viewmodel.dart';
import '../../../../core/widgets/appbar/custom_universal_back_appbar.dart';

class DetailLogbookHarianScreen extends StatelessWidget {
  final String logbookHarianUid;
  final MahasiswaLaporanViewModel viewModel;

  const DetailLogbookHarianScreen({
    super.key,
    required this.logbookHarianUid,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: viewModel.getLogbookHarianDetail(logbookHarianUid),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Tidak ada data
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Data logbook tidak ditemukan")),
          );
        }

        final data = snapshot.data!;
        final logbookData = data['logbook'] as Map<String, dynamic>;
        final mahasiswaData = data['mahasiswa'] as Map<String, dynamic>;
        final dosenData = data['dosen'] as Map<String, dynamic>;

        return Scaffold(
          appBar: CustomUniversalAppbar(
            judul: logbookData["judulTopik"] ?? "Detail Logbook",
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("Mahasiswa"),
                _readonlyField(value: mahasiswaData["name"] ?? "Mahasiswa tidak ditemukan"),

                _label("Dosen Pembimbing"),
                _readonlyField(value: dosenData["name"] ?? "Dosen tidak ditemukan"),

                _label("Judul Topik"),
                _readonlyField(value: logbookData["judulTopik"] ?? ""),

                _label("Deskripsi Kegiatan"),
                _readonlyField(value: logbookData["deskripsi"] ?? "", maxLines: 5),

                _label("Tanggal"),
                _readonlyField(
                  value: logbookData["tanggal"] != null
                      ? MahasiswaLaporanViewModel.formatTanggal(logbookData["tanggal"])
                      : "Tanggal tidak tersedia",
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  Widget _readonlyField({required String value, int maxLines = 1}) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
