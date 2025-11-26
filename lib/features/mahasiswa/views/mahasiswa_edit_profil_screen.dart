import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mahasiswa_viewmodel.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_universal_back_appBar.dart';

class MahasiswaEditProfilScreen extends StatefulWidget {
  const MahasiswaEditProfilScreen({super.key});

  @override
  State<MahasiswaEditProfilScreen> createState() => _MahasiswaEditProfilScreenState();
}

class _MahasiswaEditProfilScreenState extends State<MahasiswaEditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  TextEditingController? _phoneController;
  bool _controllersInitialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MahasiswaViewModel>().loadmahasiswaData();
    });
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _emailController?.dispose();
    _phoneController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MahasiswaViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (vm.mahasiswaData == null) {
          return const Scaffold(body: Center(child: Text('Data tidak tersedia')));
        }

        final data = vm.mahasiswaData!;

        if (!_controllersInitialized) {
          _nameController = TextEditingController(text: data.name);
          _emailController = TextEditingController(text: data.email);
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
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                                  final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
                                  if (!emailRegex.hasMatch(v.trim())) return 'Format email tidak valid';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(labelText: 'Nomor Telepon', border: OutlineInputBorder()),
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),

                          vm.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                    onPressed: () async {
                                      if (!_formKey.currentState!.validate()) return;

                                      final newName = _nameController!.text.trim();
                                      final newEmail = _emailController!.text.trim();
                                      final newPhone = _phoneController!.text.trim().isEmpty ? null : _phoneController!.text.trim();

                                      try {
                                        await vm.updateProfile(name: newName, email: newEmail, phoneNumber: newPhone);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui')));
                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui profil: $e')));
                                        }
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      child: Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
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