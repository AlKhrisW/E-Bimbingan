import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/mahasiswa_viewmodel.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

class MahasiswaEditProfilScreen extends StatefulWidget {
  const MahasiswaEditProfilScreen({super.key});

  @override
  State<MahasiswaEditProfilScreen> createState() => _MahasiswaEditProfilScreenState();
}

class _MahasiswaEditProfilScreenState extends State<MahasiswaEditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller hanya untuk Nama dan No HP (sesuai ViewModel baru)
  TextEditingController? _nameController;
  TextEditingController? _phoneController;
  
  bool _controllersInitialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Memanggil fungsi load sesuai nama di ViewModel Mahasiswa
      context.read<MahasiswaViewModel>().loadmahasiswaData();
    });
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _phoneController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MahasiswaViewModel>(
      builder: (context, vm, child) {
        // 1. Handle Loading State
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. Handle Null Data State
        if (vm.mahasiswaData == null) {
          return const Scaffold(body: Center(child: Text('Data tidak tersedia')));
        }

        final data = vm.mahasiswaData!;

        // 3. Initialize Controllers (hanya sekali saat data tersedia)
        if (!_controllersInitialized) {
          _nameController = TextEditingController(text: data.name);
          _phoneController = TextEditingController(text: data.phoneNumber ?? '');
          _controllersInitialized = true;
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: CustomUniversalAppbar(judul: "Edit Profil"),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // Styling border disamakan dengan DosenEditProfil
                    border: Border.all(color: AppTheme.primaryColor, width: 3),
                    color: Colors.white,
                  ),
                  child: Form(
                    key: _formKey,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 360),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              // Field Nama
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama', 
                                  border: OutlineInputBorder()
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) 
                                    ? 'Nama tidak boleh kosong' 
                                    : null,
                              ),
                              const SizedBox(height: 30),
                              // Field Nomor Telepon
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Nomor Telepon', 
                                  border: OutlineInputBorder()
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),

                          // Tombol Simpan
                          vm.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(48)
                                    ),
                                    onPressed: () async {
                                      if (!_formKey.currentState!.validate()) return;

                                      final newName = _nameController!.text.trim();
                                      final newPhone = _phoneController!.text.trim().isEmpty 
                                          ? null 
                                          : _phoneController!.text.trim();

                                      try {
                                        // Panggil updateProfile di ViewModel
                                        await vm.updateProfile(
                                          name: newName, 
                                          phoneNumber: newPhone
                                        );
                                        
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Profil berhasil diperbarui'))
                                          );
                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Gagal memperbarui profil: $e'))
                                          );
                                        }
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      child: Text(
                                        'Simpan Perubahan', 
                                        style: TextStyle(fontSize: 16)
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
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