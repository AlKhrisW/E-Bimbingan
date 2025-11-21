// lib/features/admin/views/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/user_model.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../auth/views/login_page.dart';
import '../../../../core/themes/app_theme.dart';
import '../viewmodels/admin_viewmodel.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel user;
  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<Map<String, int>> _userCountsFuture;

  final List<Map<String, dynamic>> _statusData = [
    {'label': 'Disetujui', 'value': 45, 'color': Colors.green},
    {'label': 'Dalam Proses', 'value': 25, 'color': Colors.yellow},
    {'label': 'Ditolak', 'value': 10, 'color': Colors.red},
    {'label': 'Belum Dikerjakan', 'value': 20, 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    _userCountsFuture = _fetchDashboardCounts();
  }

  Future<Map<String, int>> _fetchDashboardCounts() async {
    final viewModel = Provider.of<AdminViewModel>(context, listen: false);
    final allUsers = await viewModel.fetchAllUsers();

    final totalAdmin = allUsers.where((u) => u.role == 'admin').length;
    final totalDosen = allUsers.where((u) => u.role == 'dosen').length;
    final totalMahasiswa = allUsers.where((u) => u.role == 'mahasiswa').length;
    final totalUser = allUsers.length;

    return {
      'total': totalUser,
      'mahasiswa': totalMahasiswa,
      'dosen': totalDosen,
      'admin': totalAdmin,
    };
  }

  void _handleLogout(BuildContext context) async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    await viewModel.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // Widget Helper untuk Card Jumlah (SAMA PERSIS, HANYA WARNA YANG BERBEDA)
  Widget _buildCountCard(String title, String count, Color bgColor, Color textColor) {
    return Card(
      color: bgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStatusChart(int percentage) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percentage%',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  const Text('Aktivitas\nBimbingan', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
          Wrap(
            spacing: 15,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _statusData.map((item) => _buildLegend(item['label'], item['color'] as Color)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalLogbooks = _statusData.fold<int>(0, (sum, item) => sum + item['value'] as int);
    final completionPercentage = totalLogbooks == 0 ? 0 : ((_statusData[0]['value'] / totalLogbooks) * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: const Text('Beranda Admin', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifikasi Tekan!')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Text('A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  backgroundColor: AppTheme.primaryColor,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user.name.split(' ')[0] + ' 👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text(widget.user.role == 'admin' ? 'Super Admin' : 'Admin', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- CARD JUMLAH USER DENGAN WARNA BERBEDA ---
            Text('Users', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            FutureBuilder<Map<String, int>>(
              future: _userCountsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? {'total': 0, 'mahasiswa': 0, 'dosen': 0, 'admin': 0};

                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.5, // TETAP DIPAKAI
                  children: [
                    // 1. Jumlah User - BIRU MUDA
                    _buildCountCard(
                      'Jumlah User',
                      data['total'].toString(),
                      const Color(0xFFE3F2FD), // #E3F2FD
                      const Color(0xFF1976D2), // #1976D2
                    ),

                    // 2. Jumlah Mahasiswa - HIJAU MUDA
                    _buildCountCard(
                      'Jumlah Mahasiswa',
                      data['mahasiswa'].toString(),
                      const Color(0xFFE8F5E9), // #E8F5E9
                      const Color(0xFF388E3C), // #388E3C
                    ),

                    // 3. Jumlah Dosen - KUNING/ORANYE MUDA
                    _buildCountCard(
                      'Jumlah Dosen',
                      data['dosen'].toString(),
                      const Color(0xFFFFF3E0), // #FFF3E0
                      const Color(0xFFF57C00), // #F57C00
                    ),

                    // 4. Jumlah Admin - UNGU MUDA
                    _buildCountCard(
                      'Jumlah Admin',
                      data['admin'].toString(),
                      const Color(0xFFF3E5F5), // #F3E5F5
                      const Color(0xFF7B1FA2), // #7B1FA2
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // --- STATUS KEGIATAN ---
            Text('Status Kegiatan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildActivityStatusChart(completionPercentage),

            const SizedBox(height: 30),

            // --- STATISTIK ---
            Text('Statistik', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('Grafik Garis Placeholder')),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}