import 'package:cloud_firestore/cloud_firestore.dart';

// digunakan untuk status ajuan jadwal bimbingan
enum AjuanStatus {
  proses, // diajukan oleh mahasiswa, menunggu persetujuan dosen
  disetujui, // dosen menyetujui jadwal
  ditolak, // dosen menolak ajuan jadwal
}

class AjuanBimbinganModel {
  final String ajuanUid;
  final String mahasiswaUid;
  final String dosenUid;
  
  // data jadwal yang diajukan/disetujui
  final String judulTopik; 
  final String waktuBimbingan; // format hh:mm string
  final DateTime tanggalBimbingan; // tanggal sesi bimbingan yang disetujui/diajukan
  
  // metadata tracking
  final AjuanStatus status;
  final DateTime waktuDiajukan; // timestamp saat mahasiswa membuat ajuan
  final String? keterangan; // alasan jika ajuan ditolak

  AjuanBimbinganModel({
    required this.ajuanUid,
    required this.mahasiswaUid,
    required this.dosenUid,
    required this.judulTopik,
    required this.waktuBimbingan,
    required this.tanggalBimbingan,
    required this.status,
    required this.waktuDiajukan, 
    this.keterangan,
  });

  factory AjuanBimbinganModel.fromMap(Map<String, dynamic> data) {
    // fungsi frommap untuk deserialisasi data dari firestore
    return AjuanBimbinganModel(
      ajuanUid: data['ajuanUid'] ?? '',
      mahasiswaUid: data['mahasiswaUid'] ?? '',
      dosenUid: data['dosenUid'] ?? '',
      judulTopik: data['judulTopik'] ?? 'tanpa judul',
      waktuBimbingan: data['waktuBimbingan'] ?? 'n/a',
      // konversi timestamp ke datetime
      tanggalBimbingan: (data['tanggalBimbingan'] as Timestamp).toDate(),
      waktuDiajukan: (data['waktuDiajukan'] as Timestamp).toDate(), 
      // konversi string ke enum
      status: AjuanStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => AjuanStatus.proses,
      ),
      keterangan: data['keterangan'],
    );
  }

  Map<String, dynamic> toMap() {
    // fungsi tomap untuk serialisasi data ke firestore
    return {
      'ajuanUid': ajuanUid,
      'mahasiswaUid': mahasiswaUid,
      'dosenUid': dosenUid,
      'judulTopik': judulTopik,
      'waktuBimbingan': waktuBimbingan,
      // simpan sebagai timestamp
      'tanggalBimbingan': Timestamp.fromDate(tanggalBimbingan), 
      'waktuDiajukan': Timestamp.fromDate(waktuDiajukan),
      // simpan enum sebagai string lowercase
      'status': status.toString().split('.').last, 
      
      // keterangan selalu dikirim (null jika kosong)
      'keterangan': keterangan,
    };
  }
}