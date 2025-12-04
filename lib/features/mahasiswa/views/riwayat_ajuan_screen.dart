// lib/features/mahasiswa/pages/riwayat_ajuan_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/appbar/custom_appbar.dart';
import '../../../data/models/user_model.dart';
import '../widgets/mahasiswa_navbar_config.dart';
import '../viewmodels/ajuan_bimbingan_viewmodel.dart';
import '../../../data/models/ajuan_bimbingan_model.dart';
import 'mahasiswa_ajuan_screen.dart';
import 'detail_ajuan_screen.dart';

class RiwayatAjuanScreen extends StatelessWidget {
  final UserModel user;

  const RiwayatAjuanScreen({super.key, required this.user});

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

  @override
  Widget build(BuildContext context) {
    final viewModel = AjuanBimbinganViewModel();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: const CustomAppbar(judul: "Riwayat Bimbingan"),

      body: StreamBuilder<List<AjuanBimbinganModel>>(
        stream: viewModel.getRiwayat(user.uid ?? ""),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Jika tidak ada data atau data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Belum ada riwayat bimbingan",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              const Text(
                "Riwayat Ajuan Bimbingan",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              ...data.map((item) {
                final title = item.judulTopik ?? "-";

                final date = item.tanggalBimbingan != null
                    ? item.tanggalBimbingan!.formatDate()
                    : "-";

                final status =
                    item.status.toString().replaceAll("AjuanStatus.", "");

                final color = _statusColor(status);

                return _buildBimbinganCard(
                  context: context,
                  title: title,
                  date: date,
                  status: status.capitalize(),
                  statusColor: color,
                  ajuan: item,
                );
              }).toList(),

              const SizedBox(height: 80),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MahasiswaAjuanScreen(user: user),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildBimbinganCard({
    required BuildContext context,
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required AjuanBimbinganModel ajuan,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailAjuanScreen(
              ajuan: ajuan,
              user: user,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// EXTENSIONS
extension DateFormatX on DateTime {
  String formatDate() {
    return "$day ${_monthName(month)} $year";
  }

  String _monthName(int m) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return months[m - 1];
  }
}

extension StringX on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}