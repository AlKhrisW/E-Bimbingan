import 'package:ebimbingan/data/models/logbook_harian_model.dart';
import 'package:ebimbingan/data/models/user_model.dart';

class HelperLogbookHarian {
  final LogbookHarianModel logbook;
  final UserModel mahasiswa;

  HelperLogbookHarian({
    required this.logbook,
    required this.mahasiswa,
  });
}