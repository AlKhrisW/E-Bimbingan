// lib/features/admin/views/mapping/add_mapping_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/widgets/custom_button_back.dart'; // pastikan path benar
import '../../../../../data/models/user_model.dart';
import '../../widgets/mapping/mahasiswa_selection_tile.dart';
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
        const SnackBar(content: Text('Pilih minimal satu mahasiswa untuk mapping.')),
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
        SnackBar(content: Text(_viewModel.errorMessage ?? 'Gagal menyimpan data.')),
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
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const CustomBackButton(),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              // Kartu dosen
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: AppTheme.primaryColor,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.dosen.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'dosen - ${widget.dosen.jabatan ?? 'n/a'}',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Mahasiswa...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // List mahasiswa
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredUnassignedList.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'Semua mahasiswa sudah ter-mapping.'
                                  : 'Mahasiswa tidak ditemukan.',
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredUnassignedList.length,
                            itemBuilder: (context, index) {
                              final mahasiswa = _filteredUnassignedList[index];
                              final isSelected = _selectedMahasiswaUids.contains(mahasiswa.uid);
                              return MahasiswaSelectionTile(
                                mahasiswa: mahasiswa,
                                isSelected: isSelected,
                                onTap: () => _toggleSelection(mahasiswa.uid),
                              );
                            },
                          ),
              ),
            ],
          ),

          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : _submitMapping,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: vm.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan (${_selectedMahasiswaUids.length})',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}