import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Components
import 'package:ebimbingan/core/widgets/appbar/dashboard_page_appBar.dart';
import 'package:ebimbingan/features/notifikasi/views/notifikasi_screen.dart';

// ViewModel & Widgets
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

        return Scaffold(
          appBar: user == null
              ? null
              : DashboardPageAppBar(
                  name: user.name,
                  placement: user.jabatan ?? "Dosen Pembimbing",
                  photoUrl: user.photoBase64,
                  onNotificationTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => NotificationPage()),
                    );
                  },
                ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => await vm.loadDashboardData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Jadwal ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Jadwal Mengajar",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        // Badge Jumlah Jadwal
                        if (vm.jadwalTampil.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${vm.jadwalTampil.length} Sesi",
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade800
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),

                    // --- List Jadwal Horizontal ---
                    SizedBox(
                      height: 170,
                      child: _buildJadwalList(vm),
                    ),

                    const SizedBox(height: 24),
                    
                    // --- Placeholder Statistik ---
                    const Text(
                      "Statistik Bimbingan",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Center(child: Text("Grafik Mahasiswa")),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJadwalList(DosenDashboardViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(vm.errorMessage!, textAlign: TextAlign.center),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => vm.loadDashboardData(),
            )
          ],
        ),
      );
    }

    if (vm.jadwalTampil.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event_available, color: Colors.grey),
            SizedBox(height: 8),
            Text("Tidak ada jadwal bimbingan aktif"),
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
          namaMahasiswa: item.mahasiswa.name, // Data dari Helper
          tanggal: tgl,
          jamMulai: item.ajuan.waktuBimbingan,
          topik: item.ajuan.judulTopik,
          color: Colors.indigo, // Warna tema dosen
        );
      },
    );
  }
}