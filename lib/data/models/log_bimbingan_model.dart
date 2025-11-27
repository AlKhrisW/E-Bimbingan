import 'package:cloud_firestore/cloud_firestore.dart';

// status log bimbingan mingguan yang diajukan oleh mahasiswa
enum LogBimbinganStatus {
  pending, // diajukan mahasiswa, menunggu persetujuan dosen
  approved, // dosen menyetujui, logbook harian minggu terkait otomatis verified
  rejected, // dosen menolak, mahasiswa harus revisi
}

class LogBimbinganModel {
  final String logBimbinganUid;
  final String mahasiswaUid;
  final String dosenUid;

  // detail sesi
  final DateTime tanggalSesi; 
  final String waktuSesi;
  final String topikBahasan;
  final String metodeBimbingan;
  final String ringkasanHasil;
  final String? lampiranUrl; // url link dokumen/lampiran (opsional)

  // tracking
  final LogBimbinganStatus status;
  final DateTime waktuPengajuan; 
  final String? catatanDosen; // catatan dari dosen jika rejected atau masukan

  LogBimbinganModel({
    required this.logBimbinganUid,
    required this.mahasiswaUid,
    required this.dosenUid,
    required this.tanggalSesi,
    required this.waktuSesi,
    required this.topikBahasan,
    required this.metodeBimbingan,
    required this.ringkasanHasil,
    required this.status,
    required this.waktuPengajuan,
    this.lampiranUrl,
    this.catatanDosen,
  });

  factory LogBimbinganModel.fromMap(Map<String, dynamic> data) {
    // fungsi frommap untuk deserialisasi data dari firestore
    return LogBimbinganModel(
      logBimbinganUid: data['logBimbinganUid'] ?? '',
      mahasiswaUid: data['mahasiswaUid'] ?? '',
      dosenUid: data['dosenUid'] ?? '',
      tanggalSesi: (data['tanggalSesi'] as Timestamp).toDate(),
      waktuSesi: data['waktuSesi'] ?? 'n/a',
      topikBahasan: data['topikBahasan'] ?? '',
      metodeBimbingan: data['metodeBimbingan'] ?? '',
      ringkasanHasil: data['ringkasanHasil'] ?? '',
      waktuPengajuan: (data['waktuPengajuan'] as Timestamp).toDate(),
      
      // konversi string ke enum
      status: LogBimbinganStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => LogBimbinganStatus.pending,
      ),
      lampiranUrl: data['lampiranUrl'],
      catatanDosen: data['catatanDosen'],
    );
  }

  Map<String, dynamic> toMap() {
    // fungsi tomap untuk serialisasi data ke firestore
    return {
      'logBimbinganUid': logBimbinganUid,
      'mahasiswaUid': mahasiswaUid,
      'dosenUid': dosenUid,
      'tanggalSesi': Timestamp.fromDate(tanggalSesi), // simpan sebagai timestamp
      'waktuSesi': waktuSesi,
      'topikBahasan': topikBahasan,
      'metodeBimbingan': metodeBimbingan,
      'ringkasanHasil': ringkasanHasil,
      'waktuPengajuan': Timestamp.fromDate(waktuPengajuan), // simpan sebagai timestamp
      
      // simpan enum sebagai string lowercase
      'status': status.toString().split('.').last,
      
      // selalu kirim, walaupun null
      'lampiranUrl': lampiranUrl,
      'catatanDosen': catatanDosen,
    };
  }
}