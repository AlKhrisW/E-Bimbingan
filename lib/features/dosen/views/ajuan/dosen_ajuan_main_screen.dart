import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_appbar.dart';
import 'package:ebimbingan/features/dosen/views/ajuan/validasi/list_screen.dart'; 
import 'package:ebimbingan/features/dosen/views/ajuan/riwayat/riwayat_mahasiswa_list_screen.dart';

class DosenAjuanMainScreen extends StatelessWidget {
  const DosenAjuanMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: CustomAppbar(
          judul: "Data Bimbingan",
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryColor, 
            labelColor: AppTheme.primaryColor,     
            unselectedLabelColor: Colors.grey, 
            tabs: [
              Tab(text: "Ajuan Masuk"),
              Tab(text: "Riwayat"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DosenAjuan(),
            DosenListMahasiswaAjuan()
          ],
        ),
      ),
    );
  }
}