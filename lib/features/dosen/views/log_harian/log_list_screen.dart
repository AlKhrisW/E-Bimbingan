import 'package:ebimbingan/features/dosen/widgets/dosen_header_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_error_state.dart';
import 'package:ebimbingan/features/dosen/widgets/logbook_harian/logbook_filter.dart';
import 'package:ebimbingan/features/dosen/widgets/logbook_harian/logbook_item.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_halaman_kosong.dart';
import 'detail_screen.dart';

class DosenLogbookHarian extends StatefulWidget {
  final String mahasiswaUid;

  const DosenLogbookHarian({
    super.key,
    required this.mahasiswaUid,
  });

  @override
  State<DosenLogbookHarian> createState() => _DosenLogbookHarianState();
}

class _DosenLogbookHarianState extends State<DosenLogbookHarian> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DosenLogbookHarianViewModel>()
          .pilihMahasiswa(widget.mahasiswaUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomUniversalAppbar(
        judul: "Daftar Logbook Harian",
      ),
      body: Consumer<DosenLogbookHarianViewModel>(
        builder: (context, vm, child) {
          return Column(
            children: [
              if (vm.selectedMahasiswa != null)
                DosenHeaderCard(
                  name: vm.selectedMahasiswa!.name,
                  placement: vm.selectedMahasiswa!.placement ?? "-",
                )
              else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              const LogbookFilter(),
              const SizedBox(height: 8),
              Expanded(
                child: _buildListContent(vm),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListContent(DosenLogbookHarianViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return DosenErrorState(
        message: vm.errorMessage!,
        onRetry: () => vm.pilihMahasiswa(widget.mahasiswaUid),
      );
    }

    Widget content;
    
    if (vm.logbooks.isEmpty) {
      content = const DosenHalamanKosong(
        icon: Icons.book_outlined,
        message: "Belum ada logbook harian",
        subMessage: "Mahasiswa belum mengisi logbook harian.",
      );
    } else {
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(), 
        padding: const EdgeInsets.all(16),
        itemCount: vm.logbooks.length,
        itemBuilder: (_, index) {
          final logbook = vm.logbooks[index];
          return LogbookItem(
            logbook: logbook,
            onTap: () {
              final vm = context.read<DosenLogbookHarianViewModel>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: vm, 
                    child: LogbookHarianDetail(logbook: logbook),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.pilihMahasiswa(widget.mahasiswaUid),
      child: content,
    );
  }
}