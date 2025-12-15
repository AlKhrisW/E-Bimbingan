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
          content: Text(
            _viewModel.successMessage ?? 'Mahasiswa berhasil ditambahkan',
          ),
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
            children: [
              // === HEADER DOSEN – SIMETRIS, KECIL, & ELEGAN ===
              // === HEADER DOSEN – SELARAS DENGAN CARD MAHASISWA, TAPI PUNYA IDENTITAS ===
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Card(
                  elevation: 2.5,
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1.2,
                    ), // aksen identitas
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 18,
                    ),
                    child: Row(
                      children: [
                        // Avatar dosen
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                            color: AppTheme.primaryColor.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: AppTheme.primaryColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info dosen
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.dosen.name,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Dosen • ${widget.dosen.jabatan ?? 'Tidak ada jabatan'}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Jumlah mahasiswa – tetap informatif tapi tidak mendominasi
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${mappedMahasiswa.length}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              'Mahasiswa',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // === JUDUL LIST ===
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Text(
                  'Daftar Mahasiswa Bimbingan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              // === LIST MAHASISWA ===
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : mappedMahasiswa.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${widget.dosen.name} belum memiliki mahasiswa bimbingan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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

      floatingActionButton: Consumer<DetailMappingViewModel>(
        builder: (context, vm, child) {
          return FloatingActionButton(
            onPressed: vm.isLoading ? null : _navigateToAddMapping,
            backgroundColor: AppTheme.primaryColor,
            child: vm.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Icon(Icons.add, color: Colors.white, size: 32),
          );
        },
      ),
    );
  }
}
