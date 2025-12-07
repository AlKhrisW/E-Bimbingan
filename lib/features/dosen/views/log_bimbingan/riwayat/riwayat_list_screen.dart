import 'package:ebimbingan/features/dosen/widgets/dosen_header_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_riwayat_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_error_state.dart';
import 'package:ebimbingan/core/widgets/custom_halaman_kosong.dart';
import 'package:ebimbingan/features/dosen/widgets/riwayat_bimbingan/riwayat_filter.dart';
import 'package:ebimbingan/features/dosen/widgets/riwayat_bimbingan/riwayat_item.dart';
import 'riwayat_detail_screen.dart';

class DosenRiwayatBimbingan extends StatefulWidget {
  final String mahasiswaUid;

  const DosenRiwayatBimbingan({
    super.key,
    required this.mahasiswaUid,
  });

  @override
  State<DosenRiwayatBimbingan> createState() => _DosenRiwayatBimbinganState();
}

class _DosenRiwayatBimbinganState extends State<DosenRiwayatBimbingan> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DosenRiwayatBimbinganViewModel>()
          .pilihMahasiswa(widget.mahasiswaUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomUniversalAppbar(
        judul: "Daftar Logbook Bimbingan",
      ),
      body: Consumer<DosenRiwayatBimbinganViewModel>(
        builder: (context, vm, child) {
          final m = vm.selectedMahasiswa;

          return Column(
            children: [
              if (m != null)
                DosenHeaderCard(
                  name: m.name,
                  placement: m.placement ?? '-',
                )
              else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const RiwayatFilter(),
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

  Widget _buildListContent(DosenRiwayatBimbinganViewModel vm) {
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

    if (vm.riwayatList.isEmpty) {
      content = const CustomHalamanKosong(
        icon: Icons.history_toggle_off,
        message: "Belum ada riwayat bimbingan",
        subMessage: "Mahasiswa belum memiliki data bimbingan",
        height: 0.5,
      );
    } else {
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: vm.riwayatList.length,
        itemBuilder: (_, index) {
          final bimbingan = vm.riwayatList[index];
          return RiwayatItem(
            data: bimbingan,
            onTap: () {
              final vm = context.read<DosenRiwayatBimbinganViewModel>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: vm, 
                    child: DosenRiwayatBimbinganDetail(data: bimbingan),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await vm.refresh();
      },
      child: content,
    );
  }
}