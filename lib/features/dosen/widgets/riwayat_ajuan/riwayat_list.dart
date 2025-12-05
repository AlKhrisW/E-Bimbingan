import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/features/dosen/viewmodels/riwayat_ajuan_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/riwayat_ajuan/riwayat_item.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_error_state.dart'; 

class RiwayatList extends StatelessWidget {
  final String mahasiswaUid;

  const RiwayatList({
    super.key,
    required this.mahasiswaUid,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenRiwayatAjuanViewModel>(
      builder: (_, vm, __) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.errorMessage != null) {
          return DosenErrorState(
            message: vm.errorMessage!,
            onRetry: () => vm.pilihMahasiswa(mahasiswaUid),
          );
        }

        if (vm.riwayatList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 12),
                const Text(
                  "Belum ada riwayat bimbingan",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
             vm.refresh();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.riwayatList.length,
            itemBuilder: (_, index) {
              final ajuan = vm.riwayatList[index];
              return RiwayatItem(ajuan: ajuan);
            },
          ),
        );
      },
    );
  }
}