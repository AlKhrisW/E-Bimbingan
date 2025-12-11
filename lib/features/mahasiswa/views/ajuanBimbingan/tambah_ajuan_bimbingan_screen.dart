import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Core & Themes
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/custom_form_text_area.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

// ViewModel
import '../../viewmodels/ajuan_bimbingan_viewmodel.dart';
import '../../widgets/success_screen.dart';

class MahasiswaTambahAjuanScreen extends StatefulWidget {
  const MahasiswaTambahAjuanScreen({super.key});

  @override
  State<MahasiswaTambahAjuanScreen> createState() => _MahasiswaTambahAjuanScreenState();
}

class _MahasiswaTambahAjuanScreenState extends State<MahasiswaTambahAjuanScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _topikController;
  late TextEditingController _metodeController;

  // State
  DateTime _pickedTanggal = DateTime.now();
  TimeOfDay _pickedTime = const TimeOfDay(hour: 09, minute: 00); // Default jam 9 pagi
  String _dosenName = "Memuat...";

  @override
  void initState() {
    super.initState();
    _topikController = TextEditingController();
    _metodeController = TextEditingController();
    
    // Load nama dosen via ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDosenInfo();
    });
  }

  Future<void> _fetchDosenInfo() async {
    final name = await context.read<MahasiswaAjuanBimbinganViewModel>().getDosenNameForCurrentUser();
    if (mounted) {
      setState(() => _dosenName = name);
    }
  }

  @override
  void dispose() {
    _topikController.dispose();
    _metodeController.dispose();
    super.dispose();
  }

  // Picker Tanggal
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _pickedTanggal,
      firstDate: DateTime.now(),
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

  // Picker Waktu
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _pickedTime,
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
      setState(() => _pickedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format Display
    final dateDisplay = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_pickedTanggal);
    final timeDisplay = "${_pickedTime.hour.toString().padLeft(2, '0')} : ${_pickedTime.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(judul: "Ajuan Bimbingan Baru"),
      body: Consumer<MahasiswaAjuanBimbinganViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN 1: INFO TUJUAN ---
                  BuildField(
                    label: "Dosen Pembimbing",
                    value: _dosenName,
                  ),

                  const SizedBox(height: 16),

                  // --- BAGIAN 2: WAKTU & TANGGAL ---
                  Row(
                    children: [
                      // Kolom Tanggal
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tanggal",
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
                                  children: [
                                    const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        dateDisplay, 
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Kolom Jam
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Jam",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _pickTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, color: Colors.grey, size: 20),
                                    const SizedBox(width: 8),
                                    Text(timeDisplay, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --- BAGIAN 3: INPUT DATA ---
                  CustomTextArea(
                    controller: _topikController,
                    label: "Topik Bimbingan",
                    hint: "Contoh: Konsultasi Bab 2 tentang Metodologi",
                    minLines: 1,
                    maxLines: 2,
                    validator: (v) => (v == null || v.isEmpty) ? "Topik wajib diisi" : null,
                  ),

                  const SizedBox(height: 16),

                  CustomTextArea(
                    controller: _metodeController,
                    label: "Rencana Metode Bimbingan",
                    hint: "Contoh: Tatap Muka di Ruang Dosen / Google Meet",
                    minLines: 2,
                    maxLines: 3,
                    validator: (v) => (v == null || v.isEmpty) ? "Metode wajib diisi" : null,
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

                        // Konversi TimeOfDay ke String format (HH:mm)
                        final formattedTime = "${_pickedTime.hour.toString().padLeft(2, '0')}:${_pickedTime.minute.toString().padLeft(2, '0')}";

                        // Action ViewModel
                        final success = await vm.submitAjuan(
                          judulTopik: _topikController.text,
                          metodeBimbingan: _metodeController.text,
                          tanggalBimbingan: _pickedTanggal,
                          waktuBimbingan: formattedTime,
                        );

                        if (success && context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SuccessScreen(
                                message: "Ajuan Bimbingan Berhasil Dikirim",
                              ),
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(vm.errorMessage ?? "Gagal mengirim ajuan")),
                          );
                        }
                      },
                      child: vm.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Kirim Ajuan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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