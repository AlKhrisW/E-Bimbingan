import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_mahasiswa_card.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_halaman_kosong.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_riwayat_viewmodel.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_mahasiswa_list_viewmodel.dart';
import 'riwayat_list_screen.dart';

class DosenListMahasiswaAjuan extends StatefulWidget {
  const DosenListMahasiswaAjuan({super.key});

  @override
  State<DosenListMahasiswaAjuan> createState() => _DosenListMahasiswaAjuanState();
}

class _DosenListMahasiswaAjuanState extends State<DosenListMahasiswaAjuan> {
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
                  final riwayatVm = context.read<DosenRiwayatAjuanViewModel>();
                  
                  // 2. Navigasi dengan membawa ViewModel tersebut
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: riwayatVm, // Lempar instance yang benar
                        child: DosenRiwayatAjuan(
                          mahasiswaUid: m.uid,
                        ),
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