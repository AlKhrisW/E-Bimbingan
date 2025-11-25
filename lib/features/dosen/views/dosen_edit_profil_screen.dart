import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dosen_viewmodel.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_universal_back_appBar.dart';

class DosenEditProfil extends StatefulWidget {
  const DosenEditProfil({super.key});

  @override
  State<DosenEditProfil> createState() => _DosenEditProfilState();
}

class _DosenEditProfilState extends State<DosenEditProfil> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DosenViewModel>().loadDosenData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (vm.dosenData == null) {
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