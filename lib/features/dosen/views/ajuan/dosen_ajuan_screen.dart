// features/dosen/views/dosen_progres_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_ajuan_bimbingan_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_ajuan_card.dart';
import 'package:ebimbingan/features/dosen/views/ajuan/dosen_ajuan_detail_screen.dart';

class DosenAjuan extends StatefulWidget {
  const DosenAjuan({super.key});

  @override
  State<DosenAjuan> createState() => _DosenAjuanState();
}

class _DosenAjuanState extends State<DosenAjuan> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DosenAjuanBimbinganViewModel>().proses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenAjuanBimbinganViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: CustomUniversalAppbar(judul: "Ajuan Bimbingan"),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.proses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Tidak ada Ajuan Bimbingan masuk'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: vm.refresh,
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => vm.refresh(),
                        child: ListView.separated(
                          itemCount: vm.proses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final m = vm.proses[index];

                            return AjuanCard(
                              name: m.mahasiswa.name,
                              judulTopik: m.ajuan.judulTopik,
                              tanggalBimbingan: DateFormat('dd MMMM yyyy').format(m.ajuan.tanggalBimbingan),
                              waktuBimbingan: m.ajuan.waktuBimbingan,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DosenAjuanDetail(ajuanData: m),
                                  ),
                                );
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