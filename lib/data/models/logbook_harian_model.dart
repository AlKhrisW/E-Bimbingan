import 'package:cloud_firestore/cloud_firestore.dart';

// digunakan untuk status verifikasi logbook harian
enum LogbookStatus {
  draft, // baru diisi mahasiswa, belum diverifikasi
  verified, // diverifikasi otomatis/manual oleh dosen/sistem
}

class LogbookHarianModel {
  final String logbookHarianUid;
  final String mahasiswaUid;
  final String dosenUid;
  final String judulTopik;
  final DateTime tanggal;
  final String deskripsi;
  final LogbookStatus status; // status wajib (draft / verified)

  LogbookHarianModel({
    required this.logbookHarianUid,
    required this.mahasiswaUid,
    required this.dosenUid,
    required this.judulTopik,
    required this.tanggal,
    required this.deskripsi,
    required this.status,
  });

  factory LogbookHarianModel.fromMap(Map<String, dynamic> data) {
    // fungsi frommap untuk deserialisasi data dari firestore
    return LogbookHarianModel(
      logbookHarianUid: data['logbookHarianUid'] ?? '',
      mahasiswaUid: data['mahasiswaUid'] ?? '',
      dosenUid: data['dosenUid'] ?? '',
      judulTopik: data['judulTopik'] ?? 'n/a',
      tanggal: (data['tanggal'] as Timestamp).toDate(), // konversi dari timestamp
      deskripsi: data['deskripsi'] ?? '',
      // konversi string ke enum
      status: LogbookStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => LogbookStatus.draft,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    // fungsi tomap untuk serialisasi data ke firestore
    return {
      'logbookHarianUid': logbookHarianUid,
      'mahasiswaUid': mahasiswaUid,
      'dosenUid': dosenUid,
      'judulTopik': judulTopik,
      'tanggal': Timestamp.fromDate(tanggal), // simpan sebagai timestamp
      'deskripsi': deskripsi,
      // simpan enum sebagai string lowercase
      'status': status.toString().split('.').last,
    };
  }
}