// lib/features/admin/views/mapping/add_mapping_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/widgets/custom_button_back.dart';
import '../../../../../data/models/user_model.dart';
import '../../viewmodels/mapping/detail_mapping_vm.dart';

class AddMappingModal extends StatefulWidget {
  final UserModel dosen;

  const AddMappingModal({super.key, required this.dosen});

  @override
  State<AddMappingModal> createState() => _AddMappingModalState();
}

class _AddMappingModalState extends State<AddMappingModal> {
  final Set<String> _selectedMahasiswaUids = {};
  String _searchQuery = '';
  late final DetailMappingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<DetailMappingViewModel>(context, listen: false);
    Future.microtask(() => _viewModel.loadUnassignedMahasiswa());
  }

  void _toggleSelection(String uid) {
    setState(() {
      if (_selectedMahasiswaUids.contains(uid)) {
        _selectedMahasiswaUids.remove(uid);
      } else {
        _selectedMahasiswaUids.add(uid);
      }
    });
  }

  List<UserModel> get _filteredUnassignedList {
    if (_searchQuery.isEmpty) {
      return _viewModel.unassignedMahasiswa;
    }
    final queryLower = _searchQuery.toLowerCase();
    return _viewModel.unassignedMahasiswa.where((mahasiswa) {
      return mahasiswa.name.toLowerCase().contains(queryLower) ||
          (mahasiswa.nim?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  Future<void> _submitMapping() async {
    if (_selectedMahasiswaUids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu mahasiswa untuk mapping.'),
        ),
      );
      return;
    }

    final success = await _viewModel.addMapping(
      _selectedMahasiswaUids.toList(),
      widget.dosen.uid,
    );

    if (success && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? 'Gagal menyimpan data.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailMappingViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Tambah Mapping',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const CustomBackButton(),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              // === CARD DOSEN – SPACING LEBIH NYAMAN & PROPORSIONAL ===
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  20,
                ), // lebih lega ke bawah
                child: Card(
                  elevation: 2.5,
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 18,
                    ),
                    child: Row(
                      children: [
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tambahkan ke bimbingan:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.dosen.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
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
                      ],
                    ),
                  ),
                ),
              ),

              // === SEARCH BAR ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Mahasiswa...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // === LIST MAHASISWA – KINI KONSISTEN DENGAN DETAIL MAPPING ===
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredUnassignedList.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Semua mahasiswa sudah ter-mapping.'
                              : 'Mahasiswa tidak ditemukan.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredUnassignedList.length,
                        itemBuilder: (context, index) {
                          final mahasiswa = _filteredUnassignedList[index];
                          final isSelected = _selectedMahasiswaUids.contains(
                            mahasiswa.uid,
                          );

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            elevation: 3,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => _toggleSelection(mahasiswa.uid),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  leading: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.primaryColor,
                                        width: 2,
                                      ),
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    mahasiswa.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '${mahasiswa.nim ?? 'N/A'} • ${mahasiswa.programStudi ?? 'Tidak ada prodi'}',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  trailing: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked,
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade400,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          // === TOMBOL SIMPAN ===
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : _submitMapping,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: vm.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan (${_selectedMahasiswaUids.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
