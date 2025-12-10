import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/custom_halaman_kosong.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_ajuan_card.dart';
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_viewmodel.dart';
import 'detail_screen.dart';

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
       context.read<DosenAjuanViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenAjuanViewModel>(
      builder: (context, vm, child) {
        
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        Widget content;
        
        if (vm.daftarAjuan.isEmpty) {
          content = const CustomHalamanKosong(
            icon: Icons.inbox,
            message: 'Tidak ada ajuan bimbingan',
            subMessage: 'Mahasiswa belum mengajukan topik bimbingan.',
            height: 0.7,
          );
        } else {
          content = ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: vm.daftarAjuan.length, 
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final m = vm.daftarAjuan[index]; 

              return AjuanCard(
                name: m.mahasiswa.name,
                judulTopik: m.ajuan.judulTopik,
                tanggalBimbingan: DateFormat('dd MMMM yyyy').format(m.ajuan.tanggalBimbingan),
                waktuBimbingan: m.ajuan.waktuBimbingan,
                onTap: () {
                  final vm = context.read<DosenAjuanViewModel>(); 

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: vm, 
                        child: DosenAjuanDetail(data: m),
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