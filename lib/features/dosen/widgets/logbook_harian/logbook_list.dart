import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/logbook_harian/logbook_error_state.dart';
import 'package:ebimbingan/features/dosen/widgets/logbook_harian/logbook_item.dart';

class LogbookList extends StatelessWidget {
  final String mahasiswaUid;

  const LogbookList({
    super.key,
    required this.mahasiswaUid,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenLogbookHarianViewModel>(
      builder: (_, vm, __) {
        if (vm.selectedMahasiswa?.uid != mahasiswaUid) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.pilihMahasiswa(mahasiswaUid);
          });
        }
        
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.errorMessage != null) {
          return LogbookErrorState(
            message: vm.errorMessage!,
            onRetry: () => vm.pilihMahasiswa(mahasiswaUid),
          );
        }

        if (vm.logbooks.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada logbook harian",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => vm.pilihMahasiswa(mahasiswaUid),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.logbooks.length,
            itemBuilder: (_, index) {
              final logbook = vm.logbooks[index];
              return LogbookItem(logbook: logbook);
            },
          ),
        );
      },
    );
  }
}
