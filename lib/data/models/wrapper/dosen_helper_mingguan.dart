import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';

/// Model wrapper untuk menggabungkan data Log + Mahasiswa + Ajuan
class HelperLogBimbingan {
  final LogBimbinganModel log;
  final UserModel mahasiswa;
  final AjuanBimbinganModel ajuan;

  HelperLogBimbingan({
    required this.log,
    required this.mahasiswa,
    required this.ajuan,
  });
}