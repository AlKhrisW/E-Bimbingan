import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Core & Themes
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/custom_form_text_area.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

// ViewModel & Models
import '../../viewmodels/log_harian_viewmodel.dart';
import '../../widgets/success_screen.dart';

class MahasiswaTambahLogHarianScreen extends StatefulWidget {
  const MahasiswaTambahLogHarianScreen({super.key});

  @override
  State<MahasiswaTambahLogHarianScreen> createState() => _MahasiswaTambahLogHarianScreenState();
}

class _MahasiswaTambahLogHarianScreenState extends State<MahasiswaTambahLogHarianScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  
  // State
  DateTime _pickedTanggal = DateTime.now();
  String _dosenName = "Memuat..."; 

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController();
    _deskripsiController = TextEditingController();
    
    // Load nama dosen via ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDosenInfo();
    });
  }

  Future<void> _fetchDosenInfo() async {
    final name = await context.read<MahasiswaLogHarianViewModel>().getDosenNameForCurrentUser();
    if (mounted) {
      setState(() => _dosenName = name);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _pickedTanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _pickedTanggal = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateDisplay = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_pickedTanggal);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(judul: "Tambah Logbook Harian"),
      body: Consumer<MahasiswaLogHarianViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN 1: INFO TUJUAN (DOSEN) ---
                  BuildField(
                    label: "Dosen Pembimbing", 
                    value: _dosenName
                  ),

                  const SizedBox(height: 16),
                  
                  // --- BAGIAN 2: TANGGAL ---
                  const Text(
                    "Tanggal Kegiatan",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateDisplay, style: const TextStyle(fontSize: 14)),
                          const Icon(Icons.calendar_month, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- BAGIAN 3: INPUT DATA ---
                  CustomTextArea(
                    controller: _judulController,
                    label: "Topik Kegiatan",
                    hint: "Contoh: Revisi Bab 1",
                    minLines: 1,
                    maxLines: 2,
                    validator: (v) => (v == null || v.isEmpty) ? "Wajib diisi" : null,
                  ),
                  
                  const SizedBox(height: 16),

                  CustomTextArea(
                    controller: _deskripsiController,
                    label: "Deskripsi Kegiatan",
                    hint: "Jelaskan detail kegiatan...",
                    minLines: 6,
                    maxLines: 10,
                    validator: (v) => (v == null || v.isEmpty) ? "Wajib diisi" : null,
                  ),

                  const SizedBox(height: 40),

                  // --- BAGIAN 4: SUBMIT ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: vm.isLoading ? null : () async {
                        if (!_formKey.currentState!.validate()) return;
                        
                        // Action ViewModel
                        final success = await vm.tambahLogbook(
                          judulTopik: _judulController.text,
                          deskripsi: _deskripsiController.text,
                          tanggal: _pickedTanggal,
                        );

                        if (success && context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SuccessScreen(message: "Logbook Berhasil Disimpan"),
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(vm.errorMessage ?? "Gagal menyimpan")),
                          );
                        }
                      },
                      child: vm.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Simpan Logbook", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}