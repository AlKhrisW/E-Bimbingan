import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_bimbingan_card.dart'; 
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_halaman_kosong.dart';
import 'detail_screen.dart';

class DosenBimbingan extends StatefulWidget {
  const DosenBimbingan({super.key});

  @override
  State<DosenBimbingan> createState() => _DosenBimbinganState();
}

class _DosenBimbinganState extends State<DosenBimbingan> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<DosenBimbinganViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenBimbinganViewModel>(
      builder: (context, vm, child) {
        
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        Widget content;
        
        if (vm.daftarLog.isEmpty) {
          content = const DosenHalamanKosong(
            icon: Icons.inbox,
            message: 'Tidak ada log bimbingan',
            subMessage: 'Mahasiswa belum mengajukan log bimbingan.',
          );
        } else {
          content = ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: vm.daftarLog.length, 
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = vm.daftarLog[index]; 

              return BimbinganCard(
                name: item.mahasiswa.name,
                judulTopik: item.ajuan.judulTopik,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DosenLogbookDetail(data: item),
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