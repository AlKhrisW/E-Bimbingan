import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';

class MahasiswaAjuanHelper {
  final AjuanBimbinganModel ajuan;
  final UserModel dosen;

  MahasiswaAjuanHelper({
    required this.ajuan,
    required this.dosen,
  });
}