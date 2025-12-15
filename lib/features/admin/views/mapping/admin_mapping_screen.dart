// lib/features/admin/views/mapping/admin_mapping_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/themes/app_theme.dart';
import '../../viewmodels/mapping/admin_dosen_list_vm.dart';
import '../../viewmodels/mapping/detail_mapping_vm.dart';
import '../../widgets/mapping/dosen_mapping_card.dart';
// import 'detail_mapping_screen.dart';

class AdminMappingScreen extends StatefulWidget {
  const AdminMappingScreen({super.key});

  @override
  State<AdminMappingScreen> createState() => _AdminMappingScreenState();
}

class _AdminMappingScreenState extends State<AdminMappingScreen> {
  late final AdminDosenListViewModel _dosenListVm;

  @override
  void initState() {
    super.initState();
    _dosenListVm = Provider.of<AdminDosenListViewModel>(context, listen: false);
    Future.microtask(() => _dosenListVm.loadDosenList());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _dosenListVm),
        ChangeNotifierProvider(create: (_) => DetailMappingViewModel()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mapping Bimbingan',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Tidak ada tombol back otomatis
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<AdminDosenListViewModel>(
                builder: (context, vm, child) {
                  return TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari Dosen...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (value) => vm.updateSearchQuery(value),
                  );
                },
              ),
            ),

            // Daftar Dosen
            Expanded(
              child: Consumer<AdminDosenListViewModel>(
                builder: (context, vm, child) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.errorMessage != null) {
                    return Center(
                      child: Text(
                        'Error: ${vm.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (vm.filteredDosenList.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada data dosen ditemukan.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: vm.filteredDosenList.length,
                    itemBuilder: (context, index) {
                      final dosen = vm.filteredDosenList[index];
                      return DosenMappingCard(dosen: dosen);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
