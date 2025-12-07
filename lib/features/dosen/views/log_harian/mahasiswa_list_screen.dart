import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_appbar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_mahasiswa_list_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_mahasiswa_card.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_halaman_kosong.dart';
import 'package:ebimbingan/features/dosen/views/log_harian/log_list_screen.dart';

class DosenProgres extends StatefulWidget {
  const DosenProgres({super.key});

  @override
  State<DosenProgres> createState() => _DosenProgresState();
}

class _DosenProgresState extends State<DosenProgres> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DosenMahasiswaViewModel>().loadMahasiswaBimbingan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenMahasiswaViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return Scaffold(
            appBar: CustomAppbar(judul: "Logbook Harian"),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        Widget content;

        if (vm.mahasiswaList.isEmpty) {
          content = const DosenHalamanKosong(
            icon: Icons.people_outline,
            message: 'Tidak ada mahasiswa',
            subMessage: 'Anda belum memiliki mahasiswa bimbingan.',
          );
        } else {
          content = ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: vm.mahasiswaList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final m = vm.mahasiswaList[index];

              return MahasiswaCard(
                name: m.name,
                placement: m.placement ?? '-',
                mahasiswaUid: m.uid,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DosenLogbookHarian(
                        mahasiswaUid: m.uid,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }

        return Scaffold(
          appBar: CustomAppbar(judul: "Logbook Harian"),
          body: RefreshIndicator(
            onRefresh: vm.refresh,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: content,
            ),
          ),
        );
      },
    );
  }
}