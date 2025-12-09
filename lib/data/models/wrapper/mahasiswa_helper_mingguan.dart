import '../../models/user_model.dart';
import '../../models/log_bimbingan_model.dart';
import '../../models/ajuan_bimbingan_model.dart';

class MahasiswaMingguanHelper {
  final LogBimbinganModel log;
  final AjuanBimbinganModel ajuan;
  final UserModel dosen;

  MahasiswaMingguanHelper({
    required this.log,
    required this.ajuan,
    required this.dosen,
  });
}