import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_mahasiswa_list_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_mahasiswa_card.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_halaman_kosong.dart';
import 'riwayat_list_screen.dart';

class DosenListMahasiswaBimbingan extends StatefulWidget {
  const DosenListMahasiswaBimbingan({super.key});

  @override
  State<DosenListMahasiswaBimbingan> createState() => _DosenListMahasiswaBimbinganState();
}

class _DosenListMahasiswaBimbinganState extends State<DosenListMahasiswaBimbingan> {
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
          return const Center(child: CircularProgressIndicator());
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
                      builder: (_) => DosenRiwayatBimbingan(
                        mahasiswaUid: m.uid,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async => vm.refresh(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        );
      },
    );
  }
}