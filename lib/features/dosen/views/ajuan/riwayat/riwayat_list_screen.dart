import 'package:ebimbingan/features/dosen/widgets/dosen_header_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_riwayat_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_error_state.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_halaman_kosong.dart';
import 'package:ebimbingan/features/dosen/widgets/riwayat_ajuan/riwayat_filter.dart';
import 'package:ebimbingan/features/dosen/widgets/riwayat_ajuan/riwayat_item.dart';
import 'riwayat_detail_screen.dart';

class DosenRiwayatAjuan extends StatefulWidget {
  final String mahasiswaUid;

  const DosenRiwayatAjuan({
    super.key,
    required this.mahasiswaUid,
  });

  @override
  State<DosenRiwayatAjuan> createState() => _DosenRiwayatAjuanState();
}

class _DosenRiwayatAjuanState extends State<DosenRiwayatAjuan> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DosenRiwayatAjuanViewModel>()
          .pilihMahasiswa(widget.mahasiswaUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomUniversalAppbar(
        judul: "Daftar Ajuan Bimbingan",
      ),
      body: Consumer<DosenRiwayatAjuanViewModel>(
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

  Widget _buildListContent(DosenRiwayatAjuanViewModel vm) {
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
      content = const DosenHalamanKosong(
        icon: Icons.history_toggle_off,
        message: "Belum ada riwayat pengajuan",
        subMessage: "Mahasiswa belum pernah mengajukan bimbingan.",
      );
    } else {
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: vm.riwayatList.length,
        itemBuilder: (_, index) {
          final ajuan = vm.riwayatList[index];
          return RiwayatItem(
            data: ajuan,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DosenAjuanRiwayatDetail(data: ajuan)
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