import 'package:cloud_firestore/cloud_firestore.dart';

// status log bimbingan mingguan yang diajukan oleh mahasiswa
enum LogBimbinganStatus {
  draft,    // menunggu mahasiswa melengkapi form sebelum diajukan
  pending,  // diajukan mahasiswa, menunggu persetujuan dosen
  approved, // dosen menyetujui, logbook harian minggu terkait otomatis verified
  rejected, // dosen menolak, mahasiswa harus revisi
}

class LogBimbinganModel {
  final String logBimbinganUid;
  final String ajuanUid;
  final String mahasiswaUid;
  final String dosenUid;

  // detail sesi
  final String ringkasanHasil;
  final String? lampiranUrl; // url link dokumen/lampiran (opsional)
  final String? fileName; // nama file lampiran

  // tracking
  final LogBimbinganStatus status;
  final DateTime waktuPengajuan; 
  final String? catatanDosen; // catatan dari dosen jika rejected atau masukan

  LogBimbinganModel({
    required this.logBimbinganUid,
    required this.ajuanUid,
    required this.mahasiswaUid,
    required this.dosenUid,
    required this.ringkasanHasil,
    required this.status,
    required this.waktuPengajuan,
    this.lampiranUrl,
    this.fileName,
    this.catatanDosen,
  });

  factory LogBimbinganModel.fromMap(Map<String, dynamic> data) {
    // fungsi frommap untuk deserialisasi data dari firestore
    return LogBimbinganModel(
      logBimbinganUid: data['logBimbinganUid'] ?? '',
      ajuanUid: data['ajuanUid'] ?? '',
      mahasiswaUid: data['mahasiswaUid'] ?? '',
      dosenUid: data['dosenUid'] ?? '',
      ringkasanHasil: data['ringkasanHasil'] ?? '',
      waktuPengajuan: (data['waktuPengajuan'] as Timestamp).toDate(),
      
      // konversi string ke enum
      status: LogBimbinganStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => LogBimbinganStatus.draft,
      ),
      lampiranUrl: data['lampiranUrl'],
      fileName: data['fileName'],
      catatanDosen: data['catatanDosen'],
    );
  }

  Map<String, dynamic> toMap() {
    // fungsi tomap untuk serialisasi data ke firestore
    return {
      'logBimbinganUid': logBimbinganUid,
      'ajuanUid': ajuanUid,
      'mahasiswaUid': mahasiswaUid,
      'dosenUid': dosenUid,
      'ringkasanHasil': ringkasanHasil,
      'waktuPengajuan': Timestamp.fromDate(waktuPengajuan),
      
      // simpan enum sebagai string lowercase
      'status': status.toString().split('.').last,
      
      // selalu kirim, walaupun null
      'lampiranUrl': lampiranUrl,
      'fileName': fileName,
      'catatanDosen': catatanDosen,
    };
  }
}