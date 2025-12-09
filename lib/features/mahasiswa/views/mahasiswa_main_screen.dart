import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models & Config
import '../../../data/models/user_model.dart';
import '../navigation/mahasiswa_navbar_config.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart';

// [2. Tambahkan Import ViewModel Mahasiswa]
import 'package:ebimbingan/features/mahasiswa/viewmodels/mahasiswa_viewmodel.dart';
import 'package:ebimbingan/features/mahasiswa/viewmodels/log_harian_viewmodel.dart';
import 'package:ebimbingan/features/mahasiswa/viewmodels/log_mingguan_viewmodel.dart';
import 'package:ebimbingan/features/mahasiswa/viewmodels/ajuan_bimbingan_viewmodel.dart';

class MahasiswaMainScreen extends StatelessWidget {
  final UserModel user;

  const MahasiswaMainScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final navItems = buildMahasiswaNavItems(user);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MahasiswaViewModel()),
        ChangeNotifierProvider(create: (_) => MahasiswaLogMingguanViewModel()),
        ChangeNotifierProvider(create: (_) => MahasiswaLogHarianViewModel()),
        ChangeNotifierProvider(create: (_) => MahasiswaAjuanBimbinganViewModel()),
      ],
      child: CustomBottomNavShell(
        navItems: navItems,
        heroTag: "MahasiswaNav",
      ),
    );
  }
}