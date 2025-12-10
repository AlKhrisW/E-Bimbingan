import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';
import 'package:flutter/foundation.dart'; // Tambahkan ini

class AuthUtils {
  final FirebaseAuthService _authService;

  // Constructor default (untuk digunakan di kode aplikasi)
  AuthUtils({FirebaseAuthService? authService}) 
      : _authService = authService ?? FirebaseAuthService();

  /// UID user yang sedang login (dosen / admin / mahasiswa)
  String? get currentUid => _authService.getCurrentUser()?.uid;

  /// Email user yang sedang login
  String? get currentEmail => _authService.getCurrentUser()?.email;

  /// Apakah ada user yang login?
  bool get isLoggedIn => _authService.getCurrentUser() != null;

  /// Shortcut FirebaseAuth.instance.currentUser (lebih cepat & sering dipakai)
  User? get firebaseUser => FirebaseAuth.instance.currentUser;

  /// Print debug UID (sangat membantu saat debugging!)
  void printCurrentUser() { 
    final user = _authService.getCurrentUser();
    // Gunakan debugPrint di Flutter daripada print biasa
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('CURRENT USER INFO');
    debugPrint('UID   : ${user?.uid}');
    debugPrint('Email : ${user?.email}');
    debugPrint('Length: ${user?.uid.length} karakter');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}