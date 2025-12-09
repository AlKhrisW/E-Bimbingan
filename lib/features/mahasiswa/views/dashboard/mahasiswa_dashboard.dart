import 'package:ebimbingan/core/widgets/appbar/dashboard_page_appBar.dart';
import 'package:ebimbingan/features/notifikasi/views/notifikasi_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../data/models/user_model.dart';

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
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    double startAngle = -pi / 2;
    int totalValue = values.fold(0, (sum, v) => sum + v);

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / totalValue) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MahasiswaDashboard extends StatelessWidget {
  final UserModel user;

  const MahasiswaDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardPageAppBar(
        name: user.name,
        placement: user.placement ?? "-",
        photoUrl: null,
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationPage(),
            ),
          );
        },
      ),


      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //---------------- JADWAL BIMBINGAN ----------------
              const Text(
                "Jadwal Bimbingan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildScheduleCard(
                      dosenNama: "Supriatnaaaaa",
                      tanggal: "Sabtu, 15 Oktober 2025",
                      waktu: "23.00 pm - 03.00 am",
                      color: Colors.blue,
                    ),
                    _buildScheduleCard(
                      dosenNama: "Dosen Kedua",
                      tanggal: "Sabtu, 15 Oktober 2025",
                      waktu: "23.00 pm - 03.00 am",
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              //---------------- LAPORAN BIMBINGAN ----------------
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
    );
  }

  //---------------- CARD JADWAL ----------------
  Widget _buildScheduleCard({
  required String dosenNama,
  required String tanggal,
  required String waktu,
  required MaterialColor color,
}) {
  return Container(
    width: 260,
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.shade300,
          color.shade600,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Text(
                    dosenNama.isNotEmpty ? dosenNama[0].toUpperCase() : "D",
                    style: TextStyle(
                      color: color.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dosenNama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Dosen Pembimbing",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tanggal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    waktu,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: color.shade600,
            ),
          ),
        ),
      ],
    ),
  );
}

  //---------------- CARD REPORT ----------------
  Widget _buildReportCard() {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        // ---------------- Chart dengan teks abu di tengah ----------------
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
                      color: Colors.black, // teks di dalam chart abu
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Aktivitas Bimbingan",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.grey, // teks di dalam chart abu
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // ---------------- Teks di atas legend + Legend ----------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Teks di atas legend
              const Text(
                "Aktivitas Bimbingan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              // Legend
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
