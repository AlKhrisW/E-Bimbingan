// import 'package:flutter/material.dart';
// import '../../../data/services/user_service.dart';
// // import model jika diperlukan untuk peran/role

// class AdminDashboardViewModel with ChangeNotifier {
//   // --- SERVICE LAYER ---
//   final UserService _userService = UserService();

//   // --- STATE ---
//   bool _isLoading = false;
//   // Di Dashboard, lebih baik memiliki pesan error untuk notifikasi
//   String? _errorMessage; 
//   int _totalMahasiswa = 0;
//   int _totalDosen = 0;
//   int _totalAdmin = 0;

//   // --- GETTERS ---
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   int get totalMahasiswa => _totalMahasiswa;
//   int get totalDosen => _totalDosen;
//   int get totalAdmin => _totalAdmin;

//   // --- PRIVATE HELPERS ---
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   void _setErrorMessage(String? error) {
//     _errorMessage = error;
//     notifyListeners();
//   }

//   // ========================================================================
//   // CORE METHODS
//   // ========================================================================

//   /// Memuat semua statistik pengguna (Mahasiswa, Dosen, Admin)
//   Future<void> loadStatistics() async {
//     _setLoading(true);
//     _setErrorMessage(null); // Clear previous error

//     try {
//       // Asumsi fetchAllUsers mengembalikan List<UserModel>
//       final allUsers = await _userService.fetchAllUsers();
      
//       // Hitung berdasarkan role
//       _totalMahasiswa = allUsers.where((u) => u.role == 'mahasiswa').length;
//       _totalDosen = allUsers.where((u) => u.role == 'dosen').length;
//       _totalAdmin = allUsers.where((u) => u.role == 'admin').length;
      
//       // Tidak perlu notifyListeners() di sini karena _setLoading(false) akan memanggilnya
//     } catch (e) {
//       print('❌ [DashboardVM] Error loading statistics: $e');
//       _setErrorMessage('Gagal memuat statistik: ${e.toString()}');
//       // Reset data ke 0 jika gagal
//       _totalMahasiswa = 0;
//       _totalDosen = 0;
//       _totalAdmin = 0;
//     } finally {
//       _setLoading(false); // Memanggil notifyListeners()
//     }
//   }
// }