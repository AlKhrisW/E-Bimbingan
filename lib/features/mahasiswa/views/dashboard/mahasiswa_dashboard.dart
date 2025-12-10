import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ebimbingan/core/widgets/appbar/dashboard_page_appBar.dart';
import 'package:ebimbingan/features/notifikasi/views/notifikasi_screen.dart';

// ViewModel & Widget Components
import '../../widgets/jadwal_card.dart';
import '../../viewmodels/mahasiswa_dashboard_viewmodel.dart';

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

        return Scaffold(
          appBar: user == null 
              ? null
              : DashboardPageAppBar(
                  name: user.name,
                  placement: user.placement ?? "-",
                  photoUrl: user.photoBase64,
                  onNotificationTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationPage()),
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
                    // ---------------- JADWAL SECTION ----------------
                    const Text(
                      "Jadwal Bimbingan",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 170,
                      child: _buildJadwalList(vm),
                    ),

                    const SizedBox(height: 24),

                    // ---------------- REPORT SECTION ----------------
                    const Text(
                      "Laporan Bimbingan Magang",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    _buildReportCard(), 
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJadwalList(MahasiswaDashboardViewModel vm) {
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
            Text(vm.errorMessage!, textAlign: TextAlign.center),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => vm.loadDashboardData(),
            )
          ],
        ),
      );
    }

    // 3. Cek Kosong
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
            Text("Tidak ada jadwal aktif saat ini"),
          ],
        ),
      );
    }

    // 4. Tampilkan List
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

  //---------------- CARD REPORT (Tetap Sama) ----------------
  Widget _buildReportCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Chart
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(150, 150),
                  painter: CircularProgressPainter(
                    strokeWidth: 12,
                    colors: [Colors.green, Colors.orange, Colors.amber, Colors.red],
                    values: [35, 25, 20, 20],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      "55%",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Aktivitas Bimbingan",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Aktivitas Bimbingan",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const _LegendItem(color: Colors.green, text: "Disetujui"),
                const _LegendItem(color: Colors.orange, text: "Ditolak"),
                const _LegendItem(color: Colors.amber, text: "Dalam Proses"),
                const _LegendItem(color: Colors.red, text: "Belum Dikerjakan"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER CLASSES (PAINTER & LEGEND) ---
// (Disertakan agar file tetap lengkap dan tidak error saat dicopy)

class CircularProgressPainter extends CustomPainter {
  final List<Color> colors;
  final List<int> values;
  final double strokeWidth;

  CircularProgressPainter({
    required this.colors,
    required this.values,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double total = values.fold(0, (sum, item) => sum + item);
    double startAngle = -90.0;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 360;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        radians(startAngle),
        radians(sweepAngle),
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  double radians(double degrees) => degrees * (3.1415926535897932 / 180);
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        ],
      ),
    );
  }
}