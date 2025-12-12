// File: features/mahasiswa/screens/mahasiswa_tambah_ajuan_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart';
import 'package:ebimbingan/core/widgets/custom_form_text_area.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import '../../viewmodels/ajuan_bimbingan_viewmodel.dart';
import '../../widgets/success_screen.dart';

class MahasiswaTambahAjuanScreen extends StatefulWidget {
  const MahasiswaTambahAjuanScreen({super.key});

  @override
  State<MahasiswaTambahAjuanScreen> createState() =>
      _MahasiswaTambahAjuanScreenState();
}

class _MahasiswaTambahAjuanScreenState
    extends State<MahasiswaTambahAjuanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _topikController;
  late TextEditingController _metodeController;
  DateTime _pickedTanggal = DateTime.now();
  TimeOfDay _pickedTime = const TimeOfDay(hour: 9, minute: 0);
  String _dosenName = "Memuat...";

  @override
  void initState() {
    super.initState();
    _topikController = TextEditingController();
    _metodeController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDosenInfo();
    });
  }

  Future<void> _fetchDosenInfo() async {
    final name = await context
        .read<MahasiswaAjuanBimbinganViewModel>()
        .getDosenNameForCurrentUser();
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
      initialDate: _pickedTanggal.isBefore(DateTime.now())
          ? DateTime.now()
          : _pickedTanggal,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
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
    final dateDisplay = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(_pickedTanggal);
    final timeDisplay =
        "${_pickedTime.hour.toString().padLeft(2, '0')}:${_pickedTime.minute.toString().padLeft(2, '0')}";

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
                  // === DOSEN PEMBIMBING ===
                  BuildField(label: "Dosen Pembimbing", value: _dosenName),
                  const SizedBox(height: 16),

                  // === TANGGAL & JAM ===
                  Row(
                    children: [
                      Expanded(flex: 3, child: _buildDatePicker(dateDisplay)),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: _buildTimePicker(timeDisplay)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // === TOPIK BIMBINGAN ===
                  CustomTextArea(
                    controller: _topikController,
                    label: "Topik Bimbingan",
                    hint: "Contoh: Konsultasi Bab 2 tentang Metodologi",
                    minLines: 1,
                    maxLines: 2,
                    errorText: vm.topikError,
                  ),
                  const SizedBox(height: 16),

                  // === METODE BIMBINGAN ===
                  CustomTextArea(
                    controller: _metodeController,
                    label: "Rencana Metode Bimbingan",
                    hint: "Contoh: Tatap Muka di Ruang Dosen / Google Meet",
                    minLines: 2,
                    maxLines: 3,
                    errorText: vm.metodeError,
                  ),

                  // === ERROR UMUM ===
                  if (vm.generalError != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        vm.generalError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 80,
                  ), // Memberi ruang agar tidak tertutup tombol
                ],
              ),
            ),
          );
        },
      ),

      // TOMBOL SUBMIT DIPINDAH KE bottomNavigationBar (sesuai main terbaru)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<MahasiswaAjuanBimbinganViewModel>(
          builder: (context, vm, child) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        // Optional: validasi form kalau kamu pakai validator
                        // if (!_formKey.currentState!.validate()) return;

                        final formattedTime =
                            "${_pickedTime.hour.toString().padLeft(2, '0')}:${_pickedTime.minute.toString().padLeft(2, '0')}";

                        final success = await vm.submitAjuan(
                          judulTopik: _topikController.text.trim(),
                          metodeBimbingan: _metodeController.text.trim(),
                          tanggalBimbingan: _pickedTanggal,
                          waktuBimbingan: formattedTime,
                        );

                        if (!context.mounted) return;

                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SuccessScreen(
                                message: "Ajuan Bimbingan Berhasil Dikirim",
                              ),
                            ),
                          );
                        } else if (vm.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(vm.errorMessage!)),
                          );
                        }
                      },
                child: vm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Kirim Ajuan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper Widget: Date Picker
  Widget _buildDatePicker(String display) {
    return Column(
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
                    display,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget: Time Picker
  Widget _buildTimePicker(String display) {
    return Column(
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
                Text(display, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
