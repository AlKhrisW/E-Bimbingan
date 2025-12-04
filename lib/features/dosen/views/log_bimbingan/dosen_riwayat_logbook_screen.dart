// features/dosen/views/dosen_riwayat_logbook_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_mahasiswa_list_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_mahasiswa_card.dart';

class DosenRiwayatLogbook extends StatefulWidget {
  const DosenRiwayatLogbook({super.key});

  @override
  State<DosenRiwayatLogbook> createState() => _DosenRiwayatLogbookState();
}

class _DosenRiwayatLogbookState extends State<DosenRiwayatLogbook> {
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
        return Scaffold(
          appBar: CustomUniversalAppbar(judul: "Riwayat Logbook Bimbingan"),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.mahasiswaList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Tidak ada mahasiswa yang terdaftar'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: vm.refresh,
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: vm.refresh,
                        child: ListView.separated(
                          itemCount: vm.mahasiswaList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final m = vm.mahasiswaList[index];

                            return MahasiswaCard(
                              name: m.name,
                              nim: m.nim ?? '-',
                              programStudi: m.programStudi,
                              mahasiswaUid: m.uid,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Buka detail: ${m.name}")),
                                );
                                // Navigator.push(...) ke halaman detail
                              },
                            );
                          },
                        ),
                      ),
          ),
        );
      },
    );
  }
}