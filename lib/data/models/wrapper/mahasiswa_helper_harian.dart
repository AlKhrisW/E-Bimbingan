import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/logbook_harian_model.dart';

class MahasiswaHarianHelper {
  final LogbookHarianModel logbook;
  final UserModel dosen;

  MahasiswaHarianHelper({
    required this.logbook,
    required this.dosen,
  });
}