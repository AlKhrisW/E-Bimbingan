// lib/core/utils/auth_utils.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';

class AuthUtils {
  static final FirebaseAuthService _authService = FirebaseAuthService();

  /// UID user yang sedang login (dosen / admin / mahasiswa)
  static String? get currentUid => _authService.getCurrentUser()?.uid;

  /// Email user yang sedang login
  static String? get currentEmail => _authService.getCurrentUser()?.email;

  /// Apakah ada user yang login?
  static bool get isLoggedIn => _authService.getCurrentUser() != null;

  /// Shortcut FirebaseAuth.instance.currentUser (lebih cepat & sering dipakai)
  static User? get firebaseUser => FirebaseAuth.instance.currentUser;

  /// Print debug UID (sangat membantu saat debugging!)
  static void printCurrentUser() {
    final user = _authService.getCurrentUser();
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('CURRENT USER INFO');
    print('UID   : ${user?.uid}');
    print('Email : ${user?.email}');
    print('Length: ${user?.uid.length} karakter');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}