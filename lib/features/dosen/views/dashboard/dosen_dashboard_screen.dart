import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Components
import 'package:ebimbingan/core/widgets/appbar/dashboard_page_appbar.dart';
import 'package:ebimbingan/features/notifikasi/views/notifikasi_screen.dart';

// ViewModel & Widgets
import 'package:ebimbingan/features/notifikasi/viewmodels/notifikasi_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/jadwal_card.dart';

// Import Widget Progress Card Baru (Sesuaikan path)
import '../../widgets/dosen_mahasiswa_progress_card.dart'; 

class DosenDashboard extends StatefulWidget {
  const DosenDashboard({super.key});

  @override
  State<DosenDashboard> createState() => _DosenDashboardState();
}

class _DosenDashboardState extends State<DosenDashboard> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DosenDashboardViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DosenDashboardViewModel>(
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
                placement: user?.jabatan ?? "Memuat data...",
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

  Widget _buildDashboardContent(DosenDashboardViewModel vm) {
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
            // ===========================================
            // SEKSI 1: JADWAL REMINDER (Horizontal)
            // ===========================================
            _buildSectionHeader("Jadwal Membimbing", vm.jadwalTampil.length),
            
            const SizedBox(height: 12),

            SizedBox(
              height: 170,
              child: _buildJadwalList(vm),
            ),
            
            const SizedBox(height: 24),

            // ===========================================
            // SEKSI 2: PROGRESS MAHASISWA (Vertical)
            // ===========================================
            _buildSectionHeader("Mahasiswa Bimbingan", vm.studentProgressList.length),
            
            const SizedBox(height: 12),

            if (vm.studentProgressList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text(
                  "Belum ada mahasiswa bimbingan yang terhubung.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              // ListView Vertical di dalam SingleChildScrollView
              ListView.builder(
                shrinkWrap: true, // PENTING: Agar tidak scroll sendiri, ikut parent
                physics: const NeverScrollableScrollPhysics(), // Scroll pakai parent
                itemCount: vm.studentProgressList.length,
                itemBuilder: (context, index) {
                  final data = vm.studentProgressList[index];
                  
                  // Format periode
                  String period = "Periode belum diatur";
                  if (data.mahasiswa.startDate != null && data.mahasiswa.endDate != null) {
                    final start = data.mahasiswa.startDate!;
                    final end = data.mahasiswa.endDate!;
                    period = "${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}";
                  }

                  return DosenMahasiswaProgressCard(
                    studentName: data.mahasiswa.name,
                    placement: data.mahasiswa.placement ?? "-",
                    period: period,
                    logbookCurrent: data.logbookFilled,
                    logbookTarget: data.totalDays,
                    logbookPercent: data.logbookPercent,
                    bimbinganCurrent: data.bimbinganFilled,
                    bimbinganTarget: data.totalWeeks,
                    bimbinganPercent: data.bimbinganPercent,
                  );
                },
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "$count Data",
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildJadwalList(DosenDashboardViewModel vm) {
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

        return DosenJadwalCard(
          namaMahasiswa: item.mahasiswa.name,
          tanggal: tgl,
          jamMulai: item.ajuan.waktuBimbingan,
          topik: item.ajuan.judulTopik,
        );
      },
    );
  }
}