// lib/features/mahasiswa/pages/detail_ajuan_screen.dart

import 'package:flutter/material.dart';
import '../../../data/models/ajuan_bimbingan_model.dart';
import '../../../data/models/user_model.dart';
import '../viewmodels/ajuan_bimbingan_viewmodel.dart';

class DetailAjuanScreen extends StatefulWidget {
  final AjuanBimbinganModel ajuan;
  final UserModel user;

  const DetailAjuanScreen({
    super.key,
    required this.ajuan,
    required this.user,
  });

  @override
  State<DetailAjuanScreen> createState() => _DetailAjuanScreenState();
}

class _DetailAjuanScreenState extends State<DetailAjuanScreen> {
  final _viewModel = AjuanBimbinganViewModel();
  String _dosenName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadDosenName();
  }

  Future<void> _loadDosenName() async {
    final name = await _viewModel.loadDosenName(widget.ajuan.dosenUid ?? "");
    if (mounted) {
      setState(() {
        _dosenName = name;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "proses":
        return const Color(0xFFFFA500);
      case "ditolak":
        return const Color(0xFFDC2626);
      case "disetujui":
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    const months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatTimeFromString(String? timeString) {
    if (timeString == null || timeString.isEmpty) return "-";
    
    // Parse "12:00" menjadi "12 : 00 : 00"
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      final hour = parts[0];
      final minute = parts[1];
      return "$hour : $minute : 00";
    }
    
    return timeString;
  }

  String _formatTime(DateTime? date) {
    if (date == null) return "-";
    final hour = date.hour.toString();
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return "$hour : $minute : $second";
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.ajuan.status.toString().replaceAll("AjuanStatus.", "");
    final statusColor = _statusColor(status);
    final statusCapitalized = _capitalize(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.ajuan.judulTopik ?? "Detail Bimbingan",
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mahasiswa Field
            _buildInputField(
              label: "Mahasiswa",
              value: widget.user.name ?? widget.user.email ?? "-",
            ),
            const SizedBox(height: 16),

            // Dosen Pembimbing Field
            _buildInputField(
              label: "Dosen Pembimbing",
              value: _dosenName,
            ),
            const SizedBox(height: 16),

            // Topik Bimbingan Field
            _buildInputField(
              label: "Topik Bimbingan",
              value: widget.ajuan.judulTopik ?? "-",
            ),
            const SizedBox(height: 16),

            // Waktu Bimbingan Field
            _buildInputField(
              label: "Waktu Bimbingan",
              value: _formatTimeFromString(widget.ajuan.waktuBimbingan),
            ),
            const SizedBox(height: 16),

            // Tanggal Bimbingan Field
            _buildInputField(
              label: "Tanggal Bimbingan",
              value: _formatDate(widget.ajuan.tanggalBimbingan),
            ),
            const SizedBox(height: 40),

            // Status Button (Read-only / Keterangan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusCapitalized,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String value,
    bool highlighted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: highlighted 
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE5E7EB),
              width: highlighted ? 2 : 1,
            ),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }
}