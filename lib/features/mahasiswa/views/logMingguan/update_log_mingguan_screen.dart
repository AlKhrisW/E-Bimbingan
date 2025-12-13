import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ebimbingan/core/widgets/status_card/mingguan_status_badge.dart';

// Core & Themes
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/core/widgets/custom_detail_field.dart'; 
import 'package:ebimbingan/core/widgets/custom_form_text_area.dart'; 
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';

// ViewModel & Models
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_mingguan.dart';
import 'package:ebimbingan/features/mahasiswa/viewmodels/log_mingguan_viewmodel.dart';

class UpdateLogMingguanScreen extends StatefulWidget {
  final MahasiswaMingguanHelper? dataHelper;

  const UpdateLogMingguanScreen({
    super.key,
    this.dataHelper,
  });

  @override
  State<UpdateLogMingguanScreen> createState() => _UpdateLogMingguanScreenState();
}

class _UpdateLogMingguanScreenState extends State<UpdateLogMingguanScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  late TextEditingController _ringkasanController;
  
  // State Data (Untuk menampung hasil fetch atau data konstruktor)
  MahasiswaMingguanHelper? _loadedData; 
  bool _isLoading = true; 
  
  // State Gambar
  File? _selectedFile;
  final LogBimbinganService _logService = LogBimbinganService(); 

  @override
  void initState() {
    super.initState();
    _ringkasanController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final vm = Provider.of<MahasiswaLogMingguanViewModel>(context, listen: false);

    // KASUS 1: Data dikirim via Constructor (Dari List Screen)
    if (widget.dataHelper != null) {
      _finalizeDataLoad(widget.dataHelper!);
      return;
    }

    // KASUS 2: Cek Arguments Route (Dari Notifikasi)
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // A. Jika args berupa Object Helper (Navigasi manual via pushNamed)
    if (args is MahasiswaMingguanHelper) {
       _finalizeDataLoad(args);
       return;
    }

    // B. Jika args berupa String ID (Dari Notifikasi / Deep Link)
    if (args is String) {
      // Fetch data ke server berdasarkan ID
      final data = await vm.getLogbookDetail(args);
      
      if (data != null) {
        _finalizeDataLoad(data);
      } else {
        // Handle jika data tidak ditemukan (misal terhapus)
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data logbook tidak ditemukan")),
          );
          Navigator.pop(context); // Kembali
        }
      }
    } else {
      // Error: Tidak ada data maupun argumen valid
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    }
  }

  // Fungsi helper untuk set data ke state dan controller
  void _finalizeDataLoad(MahasiswaMingguanHelper data) {
    if (!mounted) return;
    setState(() {
      _loadedData = data;
      _ringkasanController.text = data.log.ringkasanHasil;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _ringkasanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, 
      maxWidth: 1000,
    );

    if (picked != null) {
      setState(() {
        _selectedFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadedData == null) {
      return const Scaffold(
        body: Center(child: Text("Gagal memuat data logbook")),
      );
    }

    final log = _loadedData!.log;
    final ajuan = _loadedData!.ajuan;
    final dosen = _loadedData!.dosen;
    final formatDate = DateFormat('dd MMMM yyyy', 'id_ID').format(ajuan.tanggalBimbingan);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomUniversalAppbar(judul: "Update Logbook"),
      body: Consumer<MahasiswaLogMingguanViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN 1: STATUS BADGE ---
                  MingguanStatus(status: log.status),
            
                  const SizedBox(height: 20),
                  
                  // --- BAGIAN 2: READ ONLY DATA ---
                  BuildField(
                    label: "Dosen Pembimbing",
                    value: dosen.name
                  ),
                  BuildField(
                    label: "Topik Bimbingan", 
                    value: ajuan.judulTopik
                  ),
                  BuildField(
                    label: "Jadwal Bimbingan", 
                    value: formatDate
                  ),
                  BuildField(
                    label: "Metode Bimbingan", 
                    value: ajuan.metodeBimbingan
                  ),
                  BuildField(
                    label: "Catatan Dosen",
                    value: log.catatanDosen ?? "Tidak ada catatan dari dosen pembimbing",
                  ),
                  
                  const SizedBox(height: 8),

                  // --- BAGIAN 3: EDITABLE FORM ---
                  CustomTextArea(
                    controller: _ringkasanController,
                    label: "Ringkasan Hasil & Progres",
                    hint: "Jelaskan hasil bimbingan Anda...",
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Ringkasan hasil wajib diisi";
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),

                  // --- BAGIAN 4: UPLOAD FOTO ---
                  const Text(
                    "Bukti Kehadiran (Foto)",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  _buildImageSection(log.lampiranUrl),

                  const SizedBox(height: 40),

                  // --- BAGIAN 5: TOMBOL SUBMIT ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                      ),
                      onPressed: vm.isLoading ? null : () async {
                        if (!_formKey.currentState!.validate()) return;

                        if (_selectedFile == null && (log.lampiranUrl == null || log.lampiranUrl!.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Bukti kehadiran wajib diupload"))
                          );
                          return;
                        }

                        final success = await vm.submitDraftOrRevisi(
                          logUid: log.logBimbinganUid, 
                          ringkasanBaru: _ringkasanController.text,
                          lampiranBaru: _selectedFile,
                        );

                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Logbook berhasil diajukan!"))
                          );
                          // Kembali ke halaman sebelumnya
                          Navigator.pop(context); 
                        }
                      },
                      child: vm.isLoading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text(
                              "Simpan & Ajukan",
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection(String? existingUrl) {
    Widget imageContent;

    if (_selectedFile != null) {
      imageContent = Image.file(
        _selectedFile!,
        fit: BoxFit.cover,
      );
    } else if (existingUrl != null && existingUrl.isNotEmpty) {
      imageContent = Image.memory(
        _logService.decodeBase64ToImage(existingUrl)!,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      imageContent = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text("Belum ada foto", style: TextStyle(color: Colors.grey))
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageContent, 
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(_selectedFile != null ? "Ganti Foto" : "Upload Foto"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}