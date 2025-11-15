// lib/data/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan metadata pengguna (role, nama, dll.) setelah login
  Future<UserModel> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw 'Data pengguna tidak ditemukan di database.';
    }
    return UserModel.fromMap(doc.data()!);
  }

  // Menyimpan metadata pengguna (dipanggil saat register)
  Future<void> saveUserMetadata(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  // Mengambil daftar Dosen (untuk Admin)
  Future<List<UserModel>> fetchDosenList() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'dosen')
        .get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }
  
  // Mengambil daftar Mahasiswa (untuk Admin)
  Future<List<UserModel>> fetchMahasiswaList() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'mahasiswa')
        .get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }
}