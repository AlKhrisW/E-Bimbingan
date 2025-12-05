import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_appbar.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_ajuan_card.dart';
import 'package:ebimbingan/features/dosen/views/ajuan/detail_screen.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_bimbingan_viewmodel.dart';

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
       context.read<DosenAjuanBimbinganViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenAjuanBimbinganViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: CustomAppbar(judul: "Ajuan Bimbingan"),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.daftarAjuan.isEmpty
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
                          itemCount: vm.daftarAjuan.length, 
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final m = vm.daftarAjuan[index]; 

                            return AjuanCard(
                              name: m.namaMahasiswa,
                              judulTopik: m.judulTopik,
                              tanggalBimbingan: DateFormat('dd MMMM yyyy').format(m.tanggalBimbingan),
                              waktuBimbingan: m.waktuBimbingan,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DosenAjuanDetail(ajuan: m),
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