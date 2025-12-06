import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/features/dosen/widgets/dosen_bimbingan_card.dart'; 
import 'package:ebimbingan/features/dosen/viewmodels/bimbingan_viewmodel.dart';
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
        return Padding(
          padding: const EdgeInsets.all(16),
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.daftarLog.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          const Text(
                            "Belum ada log bimbingan yang perlu diverifikasi",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => vm.refresh(),
                      child: ListView.separated(
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
                      ),
                    ),
        );
      },
    );
  }
}