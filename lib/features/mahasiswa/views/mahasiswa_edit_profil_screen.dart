import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mahasiswa_viewmodel.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_universal_back_appBar.dart';

class MahasiswaEditProfilScreen extends StatefulWidget {
  const MahasiswaEditProfilScreen({super.key});

  @override
  State<MahasiswaEditProfilScreen> createState() => _MahasiswaEditProfilScreenState();
}

class _MahasiswaEditProfilScreenState extends State<MahasiswaEditProfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MahasiswaViewModel>().loadmahasiswaData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MahasiswaViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (vm.mahasiswaData == null) {
          return const Scaffold(body: Center(child: Text('Data tidak tersedia')));
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: CustomUniversalAppbar(judul: "Edit Profil"),
        );
      },
    );
  }
}