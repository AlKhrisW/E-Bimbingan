import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../viewmodels/logbook_mingguan_viewmodel.dart';
import 'package:ebimbingan/core/widgets/appbar/custom_universal_back_appBar.dart';
import '../../widgets/success_screen.dart';
import '../../../../data/services/log_bimbingan_service.dart';

class TambahLogbookMingguanScreen extends StatefulWidget {
  final Map<String, dynamic> ajuanData;

  const TambahLogbookMingguanScreen({
    super.key,
    required this.ajuanData,
  });

  @override
  State<TambahLogbookMingguanScreen> createState() =>
      _TambahLogbookMingguanScreenState();
}

class _TambahLogbookMingguanScreenState
    extends State<TambahLogbookMingguanScreen> {
  final _ringkasanHasilController = TextEditingController();
  final LogBimbinganService _logService = LogBimbinganService();

  File? _selectedFile;
  Uint8List? _webImage;
  String? _fileName;
  String? _existingBase64Image;

  String _namaMahasiswa = 'Loading...';
  String _namaDosen = 'Loading...';
  bool _isLoadingUserData = true;

  late LogbookMingguanViewModel _viewModel;

  @override
  void dispose() {
    _ringkasanHasilController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _viewModel = LogbookMingguanViewModel(
      mahasiswaUid: widget.ajuanData['mahasiswaUid'],
    );

    _loadUserData();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final logBimbinganUid = widget.ajuanData['logBimbinganUid'];
      
      if (logBimbinganUid != null && logBimbinganUid.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('log_bimbingan')
            .doc(logBimbinganUid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          
          if (mounted) {
            setState(() {
              _ringkasanHasilController.text = data['ringkasanHasil'] ?? '';
              _existingBase64Image = data['lampiranUrl'];
              _fileName = data['fileName'] ?? (_existingBase64Image != null ? 'bukti_kehadiran.jpg' : null);
            });
          }
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadUserData() async {
    try {
      final mahasiswaUid = widget.ajuanData['mahasiswaUid'];
      final dosenUid = widget.ajuanData['dosenUid'];

      if (mahasiswaUid != null && mahasiswaUid.isNotEmpty) {
        final mahasiswaDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(mahasiswaUid)
            .get();

        if (mahasiswaDoc.exists) {
          final data = mahasiswaDoc.data()!;
          _namaMahasiswa = data['name'] ?? data['nama'] ?? 'Mahasiswa tidak ditemukan';
        }
      }

      if (dosenUid != null && dosenUid.isNotEmpty) {
        final dosenDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(dosenUid)
            .get();

        if (dosenDoc.exists) {
          final data = dosenDoc.data()!;
          _namaDosen = data['name'] ?? data['nama'] ?? 'Dosen tidak ditemukan';
        }
      }

      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _namaMahasiswa = 'Error memuat data';
          _namaDosen = 'Error memuat data';
          _isLoadingUserData = false;
        });
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 20,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked != null) {
        final extension = picked.name.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Format tidak didukung (JPG/JPEG/PNG)'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedFile = null;
            _fileName = picked.name;
            _existingBase64Image = null;
          });
        } else {
          setState(() {
            _selectedFile = File(picked.path);
            _webImage = null;
            _fileName = picked.name;
            _existingBase64Image = null;
          });
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showConfirmDialog() async {
    if (_ringkasanHasilController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ringkasan hasil tidak boleh kosong'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final isEditing = widget.ajuanData['logBimbinganUid'] != null;
    
    if (!isEditing && _selectedFile == null && _webImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bukti kehadiran wajib diupload'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Konfirmasi Submit',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Apakah kamu yakin ingin melakukan submit?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'NO',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'YES',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      ),
    );

    if (confirmed == true) {
      await _submitLogbook();
    }
  }

  Future<void> _submitLogbook() async {
    if (!mounted) return;

    try {
      final success = await _viewModel.submitLogBimbingan(
        ajuanUid: widget.ajuanData['ajuanUid'],
        mahasiswaUid: widget.ajuanData['mahasiswaUid'],
        dosenUid: widget.ajuanData['dosenUid'],
        ringkasanHasil: _ringkasanHasilController.text.trim(),
        lampiranFile: _selectedFile,
        lampiranBytes: _webImage,
        fileName: _fileName,
        existingLogBimbinganUid: widget.ajuanData['logBimbinganUid'],
      );

      if (!mounted) return;

      if (success) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              message: "Logbook Bimbingan\nBerhasil Diproses",
              onBack: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage ?? 'Gagal submit'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _getFormattedDate() {
    try {
      final tanggal = widget.ajuanData['tanggal'];

      final DateTime date = tanggal is Timestamp
          ? tanggal.toDate()
          : DateTime.parse(tanggal.toString());

      return '${date.day.toString().padLeft(2, '0')} - ${date.month.toString().padLeft(2, '0')} - ${date.year}';
    } catch (_) {
      return 'Tanggal tidak tersedia';
    }
  }

  Widget _buildImagePreview() {
    if (_webImage != null) {
      return _buildPreviewCard(Image.memory(_webImage!, fit: BoxFit.cover));
    } else if (_selectedFile != null) {
      return _buildPreviewCard(Image.file(_selectedFile!, fit: BoxFit.cover));
    } else if (_existingBase64Image != null) {
      final imageBytes = _logService.decodeBase64ToImage(_existingBase64Image!);
      if (imageBytes != null) {
        return _buildPreviewCard(Image.memory(imageBytes, fit: BoxFit.cover));
      }
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildPreviewCard(Widget imageWidget) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: imageWidget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: CustomUniversalAppbar(
          judul: widget.ajuanData['topikBimbingan'] ?? 'Konsultasi KLMN',
        ),
        body: Consumer<LogbookMingguanViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mahasiswa',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildReadOnlyField(_namaMahasiswa),
                            const SizedBox(height: 16),

                            const Text(
                              'Dosen Pembimbing',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildReadOnlyField(_namaDosen),
                            const SizedBox(height: 16),

                            const Text(
                              'Tanggal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildReadOnlyField(_getFormattedDate()),
                            const SizedBox(height: 16),

                            const Text(
                              'Ringkasan Hasil',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _ringkasanHasilController,
                              maxLines: 5,
                              minLines: 5,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Tulis ringkasan hasil bimbingan di sini...',
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Upload Bukti Kehadiran*',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Format: JPG, JPEG, PNG (Wajib diisi)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _fileName ?? 'Belum ada file dipilih',
                                      style: TextStyle(
                                        color: _fileName != null
                                            ? Colors.black87
                                            : Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: viewModel.isLoading ? null : _pickFile,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    side: const BorderSide(color: Colors.blue),
                                  ),
                                  child: const Text('Browse...'),
                                ),
                              ],
                            ),
                            
                            _buildImagePreview(),
                            
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading ? null : _showConfirmDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBackgroundColor: Colors.grey[400],
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (viewModel.isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Mengirim data...'),
                              SizedBox(height: 8),
                              Text(
                                'Mohon tunggu, jangan tutup aplikasi',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
      ),
    );
  }
}