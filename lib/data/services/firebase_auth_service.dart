// lib/data/services/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // 1. Sign In User
  Future<User?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException {
      throw 'Email atau password salah.';
    }
  }

  // 2. Register User dengan Secondary Auth Instance
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String role,
    // Field Mahasiswa
    String? dosenUid,
    String? nim,
    String? placement,
    DateTime? startDate,
    DateTime? endDate,
    // Field Dosen
    String? nip,
    String? jabatan,
    // Field Global
    String? programStudi,
    String? phoneNumber,
  }) async {
    // SIMPAN USER ADMIN YANG SEDANG LOGIN
    final User? currentAdmin = _auth.currentUser;

    FirebaseApp? tempApp;
    FirebaseAuth? tempAuth;

    try {
      // 1. BUAT SECONDARY FIREBASE INSTANCE (tidak ganggu session admin)
      tempApp = await Firebase.initializeApp(
        name: 'tempRegister_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      // 2. REGISTRASI USER BARU di secondary instance
      final UserCredential userCredential = await tempAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // 3. BUAT MODEL USER
      final UserModel newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        dosenUid: dosenUid,
        nim: nim,
        placement: placement,
        startDate: startDate,
        endDate: endDate,
        nip: nip,
        jabatan: jabatan,
        programStudi: programStudi,
        phoneNumber: phoneNumber,
      );

      // 4. SIMPAN KE FIRESTORE (menggunakan admin token yang masih aktif!)
      await _firestoreService.saveUserMetadata(newUser);

      // 5. LOGOUT USER BARU dari secondary instance
      await tempAuth.signOut();

      // 6. HAPUS SECONDARY APP
      await tempApp.delete();

      print('✅ User berhasil didaftarkan: ${newUser.email}');
      print('✅ Admin session tetap aktif: ${currentAdmin?.email}');

      return newUser;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Terjadi kesalahan saat pendaftaran.';

      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email sudah terdaftar. Gunakan email lain.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password terlalu lemah. Minimal 6 karakter.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid.';
      }

      throw errorMessage;
    } catch (e) {
      throw 'Gagal mendaftarkan user: ${e.toString()}';
    } finally {
      // CLEANUP: Pastikan secondary app dihapus meskipun error
      try {
        if (tempAuth != null) {
          await tempAuth.signOut();
        }
      } catch (e) {
        print('⚠️ Error saat signOut tempAuth: $e');
      }

      try {
        if (tempApp != null) {
          await Future.delayed(Duration(milliseconds: 500)); // Beri jeda
          await tempApp.delete();
        }
      } catch (e) {
        print('⚠️ Error saat delete tempApp: $e (bisa diabaikan)');
      }
    }
  }

  // 3. Reset Password
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // 4. Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 5. Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // 6. Stream Auth State (untuk monitoring)
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // 7. Fungsi delete user dari auth & firestore
  Future<void> deleteUser(String uid) async {
    await _firestoreService.deleteUserMetadata(uid);
  }
  
}
