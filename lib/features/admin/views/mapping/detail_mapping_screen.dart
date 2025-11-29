// lib/features/admin/views/mapping/detail_mapping_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/widgets/custom_button_back.dart';
import '../../../../../data/models/user_model.dart';
import '../../viewmodels/mapping/detail_mapping_vm.dart';
import '../../widgets/mapping/mahasiswa_mapping_card.dart';
import 'add_mapping_modal.dart';

class DetailMappingScreen extends StatefulWidget {
  final UserModel dosen;
  const DetailMappingScreen({super.key, required this.dosen});

  @override
  State<DetailMappingScreen> createState() => _DetailMappingScreenState();
}

class _DetailMappingScreenState extends State<DetailMappingScreen> {
  late final DetailMappingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<DetailMappingViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadMappedMahasiswa(widget.dosen.uid);
    });
  }

  Future<void> _loadData() async {
    await _viewModel.loadMappedMahasiswa(widget.dosen.uid);
  }

  void _navigateToAddMapping() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: AddMappingModal(dosen: widget.dosen),
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.successMessage ?? 'Mahasiswa berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      _viewModel.resetMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Bimbingan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<DetailMappingViewModel>(
        builder: (context, vm, child) {
          final mappedMahasiswa = vm.mappedMahasiswa;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Dosen + Garis Biru Muda
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primaryColor,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.dosen.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('Dosen • ${widget.dosen.jabatan ?? 'Tidak ada jabatan'}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Icon(Icons.group, color: AppTheme.primaryColor),
                            const SizedBox(height: 4),
                            Text('${mappedMahasiswa.length}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // GARIS BIRU MUDA DI BAWAH CARD DOSEN
              Container(
                height: 6,
                color: AppTheme.primaryColor.withOpacity(0.15), // biru muda transparan
              ),

              // Judul List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Mahasiswa Bimbingan (${mappedMahasiswa.length})',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                ),
              ),

              // List Mahasiswa
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : mappedMahasiswa.isEmpty
                        ? Center(
                            child: Text(
                              '${widget.dosen.name} belum membimbing mahasiswa.',
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: mappedMahasiswa.length,
                            itemBuilder: (context, index) {
                              final mahasiswa = mappedMahasiswa[index];
                              return MahasiswaMappingCard(
                                mahasiswa: mahasiswa,
                                dosen: widget.dosen,
                                onRefresh: _loadData,
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),

      // FAB dengan ikon + putih
      floatingActionButton: Consumer<DetailMappingViewModel>(
        builder: (context, vm, child) {
          return FloatingActionButton(
            onPressed: vm.isLoading ? null : _navigateToAddMapping,
            backgroundColor: AppTheme.primaryColor,
            elevation: 6,
            child: vm.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Icon(
                    Icons.add,
                    color: Colors.white, // PASTI PUTIH SEKARANG
                    size: 32,
                  ),
          );
        },
      ),
    );
  }
}