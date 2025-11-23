// lib/data/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// COLLECTION UTAMA
  CollectionReference get _users =>
      _firestore.collection('users');

  // ----------------------------------------------------------------------
  // FETCH ALL USERS
  // ----------------------------------------------------------------------
  Future<List<UserModel>> fetchAllUsers() async {
    final snapshot = await _users.get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ----------------------------------------------------------------------
  // FETCH DOSEN LIST
  // ----------------------------------------------------------------------
  Future<List<UserModel>> fetchDosenList() async {
    final snapshot =
        await _users.where('role', isEqualTo: 'dosen').get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ----------------------------------------------------------------------
  // UPDATE USER METADATA
  // ----------------------------------------------------------------------
  Future<void> updateUserMetadata(UserModel user) async {
    await _users.doc(user.uid).update(user.toMap());
  }

  // ----------------------------------------------------------------------
  // FETCH USER BY UID
  // ----------------------------------------------------------------------
  Future<UserModel> fetchUserByUid(String uid) async {
    try {
      final doc = await _users.doc(uid).get();

      if (!doc.exists) {
        throw 'User dengan UID $uid tidak ditemukan';
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw 'Gagal mengambil data user: $e';
    }
  }
}
