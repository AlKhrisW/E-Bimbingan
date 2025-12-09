import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Themes & Widgets Universal
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_FAB_button.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_appBar.dart';
import 'package:ebimbingan/core/widgets/custom_halaman_kosong.dart';

// Models & ViewModel
import '../../viewmodels/log_harian_viewmodel.dart';

// Widgets Spesifik Log Harian & Mahasiswa
import '../../widgets/log_harian/harian_item_card.dart';
import '../../widgets/log_harian/harian_filter_button.dart';
import 'package:ebimbingan/features/mahasiswa/widgets/mahasiswa_error_state.dart';

// Screens Navigasi
import 'detail_log_harian_screen.dart';
import 'tambah_log_harian_screen.dart';

class MahasiswaLogHarianScreen extends StatefulWidget {
  const MahasiswaLogHarianScreen({super.key});

  @override
  State<MahasiswaLogHarianScreen> createState() => _MahasiswaLogHarianScreenState();
}

class _MahasiswaLogHarianScreenState extends State<MahasiswaLogHarianScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MahasiswaLogHarianViewModel>().loadLogbooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppbar(
        judul: "Logbook Harian",
      ),
      
      // TOMBOL TAMBAH (FAB)
      floatingActionButton: Consumer<MahasiswaLogHarianViewModel>(
        builder: (context, vm, child) {
          return CustomAddFab(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MahasiswaTambahLogHarianScreen(),
                ),
              );
              vm.refresh();
            },
          );
        },
      ),

      body: Consumer<MahasiswaLogHarianViewModel>(
        builder: (context, vm, child) {
          return Column(
            children: [
              // 1. FILTER
              const MahasiswaLogHarianFilter(),
              
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

  Widget _buildListContent(MahasiswaLogHarianViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return MahasiswaErrorState(
        message: vm.errorMessage!,
        onRetry: vm.refresh,
      );
    }

    Widget content;

    if (vm.logbooks.isEmpty) {
      content = CustomHalamanKosong(
        icon: Icons.calendar_today_outlined,
        message: "Tidak ada logbook harian",
        subMessage: vm.activeFilter == null 
            ? "Anda belum mengisi logbook harian"
            : "Tidak ada data pada status ini",
        height: 0.5,
      );
    } else {
      // TAMPILAN LIST DATA
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // Bottom padding extra untuk FAB
        itemCount: vm.logbooks.length,
        itemBuilder: (_, index) {
          final item = vm.logbooks[index];
          
          return MahasiswaLogHarianItem(
            data: item,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MahasiswaDetailLogHarianScreen(dataHelper: item),
                ),
              );
            },
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: content,
    );
  }
}