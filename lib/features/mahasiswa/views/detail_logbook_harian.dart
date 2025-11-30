import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/custom_universal_back_appBar.dart';

class DetailLogbookHarianScreen extends StatelessWidget {
  final String logbookHarianUid;

  const DetailLogbookHarianScreen({
    super.key,
    required this.logbookHarianUid,
  });

  String _formatTanggal(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("logbook_harian")
          .doc(logbookHarianUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Data logbook tidak ditemukan")),
          );
        }

        final logbookData = snapshot.data!.data() as Map<String, dynamic>;

        final mahasiswaUid = logbookData["mahasiswaUid"];
        final dosenUid = logbookData["dosenUid"];

        return FutureBuilder(
          // Ambil data mahasiswa & dosen sekaligus
          future: Future.wait([
            FirebaseFirestore.instance.collection("users").doc(mahasiswaUid).get(),
            FirebaseFirestore.instance.collection("users").doc(dosenUid).get(),
          ]),
          builder: (context, AsyncSnapshot<List<DocumentSnapshot>> userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final mahasiswaData = userSnapshot.data![0].data() as Map<String, dynamic>?;
            final dosenData = userSnapshot.data![1].data() as Map<String, dynamic>?;

            final mahasiswaNama = mahasiswaData?["name"] ?? "Mahasiswa tidak ditemukan";
            final dosenNama = dosenData?["name"] ?? "Dosen tidak ditemukan";

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
                    _readonlyField(value: mahasiswaNama),

                    _label("Dosen Pembimbing"),
                    _readonlyField(value: dosenNama),

                    _label("Judul Topik"),
                    _readonlyField(value: logbookData["judulTopik"] ?? ""),

                    _label("Deskripsi Kegiatan"),
                    _readonlyField(value: logbookData["deskripsi"] ?? "", maxLines: 5),

                    _label("Tanggal"),
                    _readonlyField(
                      value: logbookData["tanggal"] != null
                          ? _formatTanggal(logbookData["tanggal"])
                          : "Tanggal tidak tersedia",
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // LABEL
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  // READONLY FIELD
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
