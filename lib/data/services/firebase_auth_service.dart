// lib/data/services/firebase_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart'; // Dibutuhkan untuk menyimpan metadata

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // 1. Sign In User
  Future<User?> signInUser({required String email, required String password}) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      throw 'Email atau password salah.';
    }
  }

  // 2. Register User (Digunakan oleh AdminViewModel)
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? dosenUid,
    String? nim,
    String? placement,
    DateTime? startDate,
    String? nip,
    String? jabatan,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      final UserModel newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        dosenUid: role == 'mahasiswa' ? dosenUid : null,
        nim: nim, placement: placement, startDate: startDate,
        nip: nip, jabatan: jabatan,
      );

      // Simpan metadata ke Firestore
      await _firestoreService.saveUserMetadata(newUser);

      return newUser;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Terjadi kesalahan saat pendaftaran.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email sudah terdaftar. Gunakan email lain.';
      }
      throw errorMessage;
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
}