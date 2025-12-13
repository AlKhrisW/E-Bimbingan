// lib/features/admin/views/dashboard/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../data/models/user_model.dart';
import '/../../core/themes/app_theme.dart';
import '/../../core/widgets/appbar/dashboard_page_appBar.dart';
import '../../viewmodels/dashboard/admin_dashboard_viewmodel.dart';
import '../../widgets/dashboard/summary_card_widget.dart';
import '../../widgets/dashboard/quick_action_button_widget.dart';
import '../../widgets/dashboard/unassigned_mahasiswa_card_widget.dart';
import '../../widgets/dashboard/dashboard_section_title_widget.dart';
import '../admin_users_screen.dart';
import '../mapping/admin_mapping_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserModel user;
  // Tambahkan callback untuk navigasi antar-tab
  final Function(int) onNavigateToTab;

  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.onNavigateToTab,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardViewModel>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: DashboardPageAppBar(
        name: widget.user.name,
        placement: widget.user.role == 'admin' ? 'Super Admin' : 'Admin',
        photoUrl: null,
        onNotificationTap: () {},
      ),
      body: Consumer<AdminDashboardViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.errorMessage != null) {
            return Center(
              child: Text(
                vm.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const DashboardSectionTitleWidget('Ringkasan Pengguna'),
                const SizedBox(height: 12),
                // GridView summary cards...
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    // ... SummaryCardWidgets
                    SummaryCardWidget(
                      title: 'Total Pengguna',
                      value: vm.totalUsers.toString(),
                      icon: Icons.people_alt,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      iconColor: AppTheme.primaryColor,
                    ),
                    SummaryCardWidget(
                      title: 'Mahasiswa',
                      value: vm.totalMahasiswa.toString(),
                      icon: Icons.school,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      iconColor: Colors.green.shade700,
                    ),
                    SummaryCardWidget(
                      title: 'Dosen',
                      value: vm.totalDosen.toString(),
                      icon: Icons.supervisor_account,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      iconColor: Colors.blue.shade700,
                    ),
                    SummaryCardWidget(
                      title: 'Admin',
                      value: vm.totalAdmin.toString(),
                      icon: Icons.admin_panel_settings,
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      iconColor: Colors.purple.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const DashboardSectionTitleWidget('Aksi Cepat'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionButtonWidget(
                        label: 'Kelola Users', // Ganti label agar lebih jelas
                        icon: Icons.person_add,
                        color: AppTheme.primaryColor,
                        onPressed: () {
                          // Navigasi ke Tab Users (Index 1)
                          widget.onNavigateToTab(1);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: QuickActionButtonWidget(
                        label: 'Kelola Mapping', // Ganti label agar lebih jelas
                        icon: Icons.link,
                        color: Colors.orange.shade600,
                        onPressed: () {
                          // Navigasi ke Tab Mapping (Index 2)
                          widget.onNavigateToTab(2);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                UnassignedMahasiswaCardWidget(
                  unassignedList: vm.unassignedMahasiswa,
                  onViewAll: () {
                    // Navigasi ke Tab Mapping (Index 2)
                    widget.onNavigateToTab(2);
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
