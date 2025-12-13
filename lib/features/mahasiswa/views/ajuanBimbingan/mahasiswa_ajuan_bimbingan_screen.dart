import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Themes & Widgets Universal
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_FAB_button.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_appBar.dart';
import 'package:ebimbingan/core/widgets/custom_halaman_kosong.dart';

// Models & ViewModel
import '../../viewmodels/ajuan_bimbingan_viewmodel.dart';

// Widgets Spesifik Ajuan & Mahasiswa
import '../../widgets/ajuan_bimbingan/ajuan_item_card.dart';
import '../../widgets/ajuan_bimbingan/ajuan_filter_button.dart';
import 'package:ebimbingan/features/mahasiswa/widgets/mahasiswa_error_state.dart';

// Screens Navigasi
import 'detail_ajuan_bimbingan_screen.dart';
import 'tambah_ajuan_bimbingan_screen.dart';

class MahasiswaAjuanBimbinganScreen extends StatefulWidget {
  const MahasiswaAjuanBimbinganScreen({super.key});

  @override
  State<MahasiswaAjuanBimbinganScreen> createState() => _MahasiswaAjuanBimbinganScreenState();
}

class _MahasiswaAjuanBimbinganScreenState extends State<MahasiswaAjuanBimbinganScreen> {
  @override
  void initState() {
    super.initState();
    // Memanggil fungsi load data dari ViewModel saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MahasiswaAjuanBimbinganViewModel>().loadAjuanData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppbar(
        judul: "Riwayat Ajuan",
      ),
      
      // TOMBOL TAMBAH (FAB)
      floatingActionButton: Consumer<MahasiswaAjuanBimbinganViewModel>(
        builder: (context, vm, child) {
          return CustomAddFab(
            onPressed: () async {
              // 1. CEK DULU APAKAH BOLEH MENGAJUKAN (Validasi Log Mingguan)
              final String? warningMessage = await vm.checkUntukAjuanBaru();
              
              if (!context.mounted) return;

              // 2. JIKA ADA PESAN WARNING, TAMPILKAN DIALOG
              if (warningMessage != null) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Peringatan"),
                    content: Text(warningMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Mengerti", style: TextStyle(color: AppTheme.primaryColor)),
                      ),
                    ],
                  ),
                );
              } else {
                // 3. JIKA NULL (AMAN), LANJUT KE HALAMAN TAMBAH
                final ajuanVm = context.read<MahasiswaAjuanBimbinganViewModel>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: ajuanVm,
                      child: MahasiswaTambahAjuanScreen(),
                    ),
                  ),
                );
                vm.refresh();
              }
            },
          );
        },
      ),

      body: Consumer<MahasiswaAjuanBimbinganViewModel>(
        builder: (context, vm, child) {
          return Column(
            children: [
              // 1. FILTER
              const MahasiswaAjuanFilter(),
              
              const SizedBox(height: 8),
              
              // 2. LIST CONTENT
              Expanded(
                child: _buildListContent(vm),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListContent(MahasiswaAjuanBimbinganViewModel vm) {
    // 1. Loading State
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error State (Menggunakan Widget Error Custom)
    if (vm.errorMessage != null) {
      return MahasiswaErrorState(
        message: vm.errorMessage!,
        onRetry: vm.refresh,
      );
    }

    Widget content;

    // 3. Empty State
    if (vm.filteredAjuans.isEmpty) {
      content = CustomHalamanKosong(
        icon: Icons.assignment_outlined, // Icon dokumen untuk Ajuan
        message: "Tidak ada riwayat ajuan",
        subMessage: vm.activeFilter == null 
            ? "Anda belum mengajukan bimbingan apapun"
            : "Tidak ada data pada status ini",
        height: 0.5,
      );
    } else {
      // 4. List Data State
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // Padding bawah extra untuk FAB
        itemCount: vm.filteredAjuans.length,
        itemBuilder: (_, index) {
          final item = vm.filteredAjuans[index];
          
          return MahasiswaAjuanItem(
            data: item,
            onTap: () {
              final ajuanVm = context.read<MahasiswaAjuanBimbinganViewModel>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: ajuanVm,
                    child: MahasiswaDetailAjuanScreen(dataHelper: item),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    // Refresh Indicator
    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: content,
    );
  }
}