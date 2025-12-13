// lib/features/admin/views/admin_main_screen.dart
import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../navigation/admin_navigation_config.dart';
import '../../../core/widgets/custom_bottom_nav_shell.dart'; // Tetap gunakan NavItem dari sini

class AdminMainScreen extends StatefulWidget {
  final UserModel user;
  const AdminMainScreen({super.key, required this.user});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;
  // Kunci navigasi untuk setiap tab, memungkinkan stack navigasi independen.
  late List<GlobalKey<NavigatorState>> _navigatorKeys;
  
  // Ambil konfigurasi NavItem yang sudah di-generate
  late final List<NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    // Inisialisasi navItems dan navigator keys.
    // Kita passing callback untuk pindah tab ke Dashboard.
    _navItems = buildAdminNavItems(widget.user, _onTabTapped); 
    
    _navigatorKeys = List.generate(
      _navItems.length,
      (_) => GlobalKey<NavigatorState>(),
    );
  }
  
  // Fungsi untuk menangani ketukan Bottom Nav Bar
  Future<void> _onTabTapped(int index) async {
    if (index == _currentIndex) {
      // Jika tab yang sama ditekan, pop ke root dari stack navigasi tab tersebut
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      // Pindah tab
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: _navItems.asMap().entries.map((entry) {
          final int idx = entry.key;
          final NavItem item = entry.value;
          
          return Offstage(
            // Sembunyikan semua Navigator kecuali yang aktif
            offstage: _currentIndex != idx,
            child: Navigator(
              // Setiap Navigator memiliki GlobalKey unik
              key: _navigatorKeys[idx], 
              // Route generator akan menampilkan screen awal tab
              onGenerateRoute: (settings) {
                return MaterialPageRoute(builder: (context) => item.screen);
              },
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        items: _navItems
            .map(
              (e) =>
                  BottomNavigationBarItem(icon: Icon(e.icon), label: e.label),
            )
            .toList(),
      ),
    );
  }
}