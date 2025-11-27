import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_mahasiswa_viewmodel.dart';

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
      final vm = context.read<DosenMahasiswaViewModel>();
      vm.loadForCurrentDosen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenMahasiswaViewModel>(builder: (context, vm, child) {
      return Scaffold(
        appBar: CustomUniversalAppbar(judul: "Progress Mahasiswa"),
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
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => vm.refresh(),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: vm.refresh,
                      child: ListView.separated(
                        itemCount: vm.mahasiswaList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final m = vm.mahasiswaList[index];
                          final initials = (m.name.trim().isEmpty)
                              ? 'U'
                              : m.name.trim().split(RegExp(r"\s+"))
                                  .map((s) => s.isNotEmpty ? s[0] : '')
                                  .take(2)
                                  .join()
                                  .toUpperCase();

                          return ListTile(
                            leading: CircleAvatar(child: Text(initials)),
                            title: Text(m.name),
                            subtitle: Text(m.nim ?? m.email),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Placeholder: show simple dialog with basic info
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(m.name),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('NIM: ${m.nim ?? '-'}'),
                                      const SizedBox(height: 6),
                                      Text('Email: ${m.email}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tutup'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      );
    });
  }
}