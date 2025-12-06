import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';

class AjuanWithMahasiswa {
  final AjuanBimbinganModel ajuan;
  final UserModel mahasiswa;

  AjuanWithMahasiswa({
    required this.ajuan,
    required this.mahasiswa,
  });
}