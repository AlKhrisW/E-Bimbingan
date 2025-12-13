import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ebimbingan/core/widgets/appbar/dashboard_page_appbar.dart';
import 'package:ebimbingan/features/notifikasi/views/notifikasi_screen.dart';

// ViewModel & Widget Components
import '../../widgets/jadwal_card.dart';
// IMPORT WIDGET PROGRESS (Sesuaikan path folder Anda)
import '../../widgets/dashboard/log_harian_card.dart';
import '../../widgets/dashboard/log_mingguan_card.dart';

import '../../viewmodels/mahasiswa_dashboard_viewmodel.dart';
import 'package:ebimbingan/features/notifikasi/viewmodels/notifikasi_viewmodel.dart';

class MahasiswaDashboardScreen extends StatefulWidget {
  const MahasiswaDashboardScreen({super.key});

  @override
  State<MahasiswaDashboardScreen> createState() => _MahasiswaDashboardScreenState();
}

class _MahasiswaDashboardScreenState extends State<MahasiswaDashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MahasiswaDashboardViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MahasiswaDashboardViewModel>(
      builder: (context, vm, child) {
        final user = vm.currentUser;

        return StreamBuilder<int>(
          stream: context.watch<NotificationViewModel>().unreadCountStream,
          initialData: 0,
          builder: (context, snapshot) {
            final int unreadCount = snapshot.data ?? 0;

            return Scaffold(
              appBar: DashboardPageAppBar(
                name: user?.name ?? "...", 
                placement: user?.placement ?? "Memuat data...",
                photoUrl: user?.photoBase64,
                notificationCount: unreadCount,
                onNotificationTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => NotificationPage()),
                  );
                },
              ),
              body: _buildDashboardContent(vm),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboardContent(MahasiswaDashboardViewModel vm) {
    // 1. Cek Loading
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Cek Error
    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(vm.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.loadDashboardData(),
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    // 3. Tampilkan Konten Utama (Jika Sukses)
    return RefreshIndicator(
      onRefresh: () async => await vm.loadDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===============================================
            // JADWAL
            // ===============================================
            const Text(
              "Jadwal Bimbingan Aktif",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 170,
              child: _buildJadwalList(vm),
            ),

            const SizedBox(height: 24),

            // ===============================================
            // PROGRESS CHART + PERIODE
            // ===============================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Progress Magang",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // --- TAMPILAN PERIODE ---
                if (vm.currentUser?.startDate != null && vm.currentUser?.endDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.blue.shade800),
                        const SizedBox(width: 4),
                        Text(
                          _formatPeriode(vm.currentUser!.startDate!, vm.currentUser!.endDate!),
                          style: TextStyle(
                            fontSize: 11, 
                            color: Colors.blue.shade800, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Cek apakah tanggal magang valid
            if (vm.totalDays == 0)
              _buildEmptyState()
            else
              Column(
                children: [
                  HarianProgressCard(
                    currentCount: vm.logbookFilled,
                    totalTarget: vm.totalDays,
                    progressPercentage: vm.logbookProgress,
                  ),
                  const SizedBox(height: 12),
                  MingguanProgressCard(
                    currentCount: vm.bimbinganFilled,
                    totalTarget: vm.totalWeeks,
                    progressPercentage: vm.bimbinganProgress,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Helper untuk format tanggal singkat: "12/10/24 - 12/01/25"
  String _formatPeriode(DateTime start, DateTime end) {
    String f(int n) => n.toString().padLeft(2, '0');
    String y(int year) => year.toString().substring(2); 
    
    return "${f(start.day)}/${f(start.month)}/${y(start.year)} - ${f(end.day)}/${f(end.month)}/${y(end.year)}";
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Periode magang belum diatur. Silakan hubungi admin.",
              style: TextStyle(color: Colors.orange, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalList(MahasiswaDashboardViewModel vm) {
    if (vm.jadwalTampil.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event_available, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text("Tidak ada jadwal bimbingan aktif", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: vm.jadwalTampil.length,
      itemBuilder: (context, index) {
        final item = vm.jadwalTampil[index];
        final tgl = "${item.ajuan.tanggalBimbingan.day}-${item.ajuan.tanggalBimbingan.month}-${item.ajuan.tanggalBimbingan.year}";

        return JadwalCardWidget(
          dosenNama: item.dosen.name,
          tanggal: tgl,
          jamMulai: item.ajuan.waktuBimbingan,
          topik: item.ajuan.judulTopik,
        );
      },
    );
  }
}