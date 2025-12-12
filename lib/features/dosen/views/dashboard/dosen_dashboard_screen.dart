import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Components
import 'package:ebimbingan/core/widgets/appbar/dashboard_page_appbar.dart';
import 'package:ebimbingan/features/notifikasi/views/notifikasi_screen.dart';

// ViewModel & Widgets
import 'package:ebimbingan/features/notifikasi/viewmodels/notifikasi_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/jadwal_card.dart';

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
            // --- Header Jadwal ---
            _buildSectionHeader("Jadwal Membimbing", vm.jadwalTampil.length),
            
            const SizedBox(height: 12),

            // --- List Jadwal Horizontal ---
            SizedBox(
              height: 170,
              child: _buildJadwalList(vm),
            ),
            
            // --- AREA UNTUK WIDGET LAIN ---
            const SizedBox(height: 24),
            // Tambahkan widget lain di sini jika perlu...
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
              "$count Sesi",
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
        // Format tanggal sederhana
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