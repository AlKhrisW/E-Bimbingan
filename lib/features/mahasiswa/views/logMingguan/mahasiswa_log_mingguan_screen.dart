import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widgets Universal
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_halaman_kosong.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_appBar.dart';

// Models & ViewModel
import '../../viewmodels/log_mingguan_viewmodel.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';

// Widgets Spesifik
import '../../widgets/log_mingguan/mingguan_item_card.dart';
import '../../widgets/log_mingguan/mingguan_filter_button.dart';

// Screens untuk Navigasi
import 'update_log_mingguan_screen.dart';
import 'detail_log_mingguan_screen.dart';

class MahasiswaLogMingguanScreen extends StatefulWidget {
  const MahasiswaLogMingguanScreen({super.key});

  @override
  State<MahasiswaLogMingguanScreen> createState() => _MahasiswaLogMingguanScreenState();
}

class _MahasiswaLogMingguanScreenState extends State<MahasiswaLogMingguanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MahasiswaLogMingguanViewModel>().loadLogData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppbar(
        judul: "Logbook Bimbingan",
      ),
      body: Consumer<MahasiswaLogMingguanViewModel>(
        builder: (context, vm, child) {
          return Column(
            children: [
              // 1. FILTER
              const MahasiswaLogFilter(),
              
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

  Widget _buildListContent(MahasiswaLogMingguanViewModel vm) {
    // 1. Handle Loading
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Handle Error
    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: vm.refresh,
                child: const Text("Coba Lagi"),
              )
            ],
          ),
        ),
      );
    }

    // 3. Tentukan Content (Kosong atau List)
    Widget content;

    if (vm.filteredLogs.isEmpty) {
      // TAMPILAN KOSONG
      content = CustomHalamanKosong(
        icon: Icons.history_edu,
        message: "Tidak ada logbook",
        subMessage: vm.activeFilter == null 
            ? "Anda belum memiliki riwayat bimbingan"
            : "Tidak ada data pada status ini",
        height: 0.5,
      );
    } else {
      // TAMPILAN LIST DATA
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: vm.filteredLogs.length,
        itemBuilder: (_, index) {
          final item = vm.filteredLogs[index];
          
          return MahasiswaLogItem(
            data: item,
            onTap: () async {
              // --- LOGIKA NAVIGASI BERDASARKAN STATUS ---
              
              if (item.log.status == LogBimbinganStatus.draft || 
                  item.log.status == LogBimbinganStatus.rejected) {
                
                final mingguanVm = context.read<MahasiswaLogMingguanViewModel>();
                
                // DRAFT / REVISI -> Ke Halaman Update
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: mingguanVm,
                      child: UpdateLogMingguanScreen(dataHelper: item),
                    ),
                  ),
                );
                
                vm.refresh();

              } else {
                
                // PENDING / APPROVED -> Ke Halaman Detail
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailLogMingguanScreen(data: item),
                  ),
                );
              }
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