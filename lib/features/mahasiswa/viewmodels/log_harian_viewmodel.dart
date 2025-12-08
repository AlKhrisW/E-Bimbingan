import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../data/models/logbook_harian_model.dart';

class MahasiswaLaporanViewModel extends ChangeNotifier {
  final String mahasiswaUid;

  MahasiswaLaporanViewModel({required this.mahasiswaUid});

  // ===================== STREAM LAPORAN =====================
  Stream<QuerySnapshot> get laporanStream {
    return FirebaseFirestore.instance
        .collection("logbook_harian")
        .where("mahasiswaUid", isEqualTo: mahasiswaUid)
        .orderBy("tanggal", descending: true)
        .snapshots();
  }

  // Convert QuerySnapshot ke List<Map>
  List<Map<String, dynamic>> mapLaporan(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        "id": doc.id,
        "tanggalRaw": data["tanggal"],
        "tanggal": formatTanggal(data["tanggal"]),
        "judulTopik": data["judulTopik"] ?? "",
        "deskripsi": data["deskripsi"] ?? "",
      };
    }).toList();
  }

  // Optional: convert ke List<LogbookHarianModel>
  List<LogbookHarianModel> mapToModel(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return LogbookHarianModel.fromMap({
        ...data,
        "logbookHarianUid": doc.id,
      });
    }).toList();
  }

  // Group laporan by tanggal
  Map<String, List<Map<String, dynamic>>> groupByTanggal(List<Map<String, dynamic>> laporan) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in laporan) {
      final tgl = item["tanggal"];
      if (!grouped.containsKey(tgl)) grouped[tgl] = [];
      grouped[tgl]!.add(item);
    }
    return grouped;
  }

  // ===================== USER FETCHING =====================
  Future<Map<String, dynamic>> getUserByUid(String uid) async {
    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (!doc.exists) return {};
    return doc.data() as Map<String, dynamic>;
  }

  // ===================== DETAIL LOGBOOK =====================
  Future<Map<String, dynamic>> getLogbookHarianDetail(String logbookUid) async {
    final doc = await FirebaseFirestore.instance.collection("logbook_harian").doc(logbookUid).get();
    if (!doc.exists) throw Exception("Logbook tidak ditemukan");

    final logbookData = doc.data() as Map<String, dynamic>;

    final mahasiswaData = await getUserByUid(logbookData["mahasiswaUid"]);
    final dosenData = await getUserByUid(logbookData["dosenUid"]);

    return {
      "logbook": logbookData,
      "mahasiswa": mahasiswaData,
      "dosen": dosenData,
    };
  }

  // Optional: helper return LogbookHarianModel
  Future<LogbookHarianModel> getLogbookHarianModel(String logbookUid) async {
    final doc = await FirebaseFirestore.instance.collection("logbook_harian").doc(logbookUid).get();
    if (!doc.exists) throw Exception("Logbook tidak ditemukan");

    final data = doc.data() as Map<String, dynamic>;
    return LogbookHarianModel.fromMap({
      ...data,
      "logbookHarianUid": doc.id,
    });
  }

  // ===================== FORMAT TANGGAL =====================
  static String formatTanggal(Timestamp ts) {
    final date = ts.toDate();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final thisDate = DateTime(date.year, date.month, date.day);

    if (thisDate == today) return "Today";
    if (thisDate == today.subtract(const Duration(days: 1))) return "Yesterday";

    return "${date.day} ${_namaBulan(date.month)}";
  }

  static String _namaBulan(int m) {
    const bulan = [
      "",
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return bulan[m];
  }
}
