// lib/data/services/user_service.dart
// VERSI BASE64 - SIMPAN DI FIRESTORE (GRATIS!)
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();
  CollectionReference get _users => _firestore.collection('users');

  // ========================================================================
  // EXISTING METHODS (TIDAK BERUBAH)
  // ========================================================================
  Future<List<UserModel>> fetchAllUsers() async {
    final snapshot = await _users.get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserModel>> fetchDosenList() async {
    final snapshot = await _users.where('role', isEqualTo: 'dosen').get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateUserMetadata(UserModel user) async {
    await _users.doc(user.uid).update(user.toMap());
  }

  // Partial update: only update provided fields for the user document
  Future<void> updateUserMetadataPartial(
    String uid,
    Map<String, dynamic> data,
  ) async {
    if (data.isEmpty) return;
    await _users.doc(uid).update(data);
  }

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

  // Ambil daftar mahasiswa yang terdaftar pada dosen tertentu (menggunakan field `dosen_uid`)
  Future<List<UserModel>> fetchMahasiswaByDosenUid(String dosenUid) async {
    try {
      final snapshot = await _users
          .where('role', isEqualTo: 'mahasiswa')
          .where('dosen_uid', isEqualTo: dosenUid)
          .get();

      final result = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      print('[UserService] Mahasiswa dibimbing $dosenUid: ${result.length} orang');
      return result;
    } catch (e) {
      print('Error fetching mahasiswa by dosenUid: $e');
      rethrow;
    }
  }

  // ========================================================================
  // PHOTO PROFILE METHODS (BASE64 VERSION) — TETAP SAMA
  // ========================================================================
  Future<bool> updateProfilePhoto(String uid, File imageFile) async {
    try {
      print('Starting photo update for UID: $uid');
      if (!_storageService.isImageFile(imageFile)) {
        throw 'File harus berupa gambar (jpg, png, gif, webp)';
      }
      if (!_storageService.isFileSizeValid(imageFile, maxSizeInMB: 2)) {
        throw 'Ukuran file maksimal 2MB';
      }

      print('Converting to Base64...');
      final base64String = await _storageService.imageToBase64(imageFile);
      if (base64String == null || base64String.isEmpty) {
        throw 'Gagal mengkonversi foto';
      }
      print('Base64 conversion success');

      await _users.doc(uid).update({
        'photo_base64': base64String,
      });
      print('Firestore updated successfully');
      return true;
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.code} - ${e.message}');
      throw 'Error Firebase: ${e.message ?? 'Terjadi kesalahan'}';
    } on SocketException catch (e) {
      print('Network error: $e');
      throw 'Tidak ada koneksi internet';
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<bool> removeProfilePhoto(String uid) async {
    try {
      print('Removing photo for UID: $uid');
      await _users.doc(uid).update({'photo_base64': FieldValue.delete()});
      print('Photo removed successfully');
      return true;
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.code} - ${e.message}');
      throw 'Error Firebase: ${e.message ?? 'Terjadi kesalahan'}';
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<String?> getProfilePhotoBase64(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) {
        print('User $uid not found');
        return null;
      }
      final data = doc.data() as Map<String, dynamic>?;
      final photoBase64 = data?['photo_base64'] as String?;
      if (photoBase64 != null && photoBase64.isNotEmpty) {
        print('Photo Base64 found for $uid');
      } else {
        print('No photo for $uid');
      }
      return photoBase64;
    } catch (e) {
      print('Error getting photo: $e');
      return null;
    }
  }

  Future<bool> hasProfilePhoto(String uid) async {
    try {
      final photoBase64 = await getProfilePhotoBase64(uid);
      return photoBase64 != null && photoBase64.isNotEmpty;
    } catch (e) {
      print('Error checking photo: $e');
      return false;
    }
  }

  /// mengambil daftar mahasiswa yang belum memiliki dosen pembimbing
  Future<List<UserModel>> fetchMahasiswaUnassigned() async {
    try {
      final snapshot = await _users.where('role', isEqualTo: 'mahasiswa').get();

      final result = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((user) => user.dosenUid == null || user.dosenUid!.isEmpty)
          .toList();

      print('[UserService] Mahasiswa unassigned: ${result.length} orang');
      return result;
    } catch (e) {
      print('error fetching unassigned mahasiswa: $e');
      rethrow;
    }
  }

  // ========================================================================
  // MAPPING METHOD — DIPERBAIKI TOTAL! (INI YANG BIKIN JUMLAH 0)
  // ========================================================================
  /// melakukan batch update pada relasi dosen_uid untuk beberapa mahasiswa
  Future<void> batchUpdateDosenRelasi({
    required List<String> mahasiswaUids,
    String? newDosenUid, // null = hapus relasi
  }) async {
    if (mahasiswaUids.isEmpty) return;

    final batch = _firestore.batch();

    for (var uid in mahasiswaUids) {
      final docRef = _users.doc(uid);

      if (newDosenUid == null) {
        // HAPUS FIELD dosen_uid dari dokumen (bukan set null!)
        batch.update(docRef, {
          'dosen_uid': FieldValue.delete(),
        });
      } else {
        // TAMBAH / UBAH dosen_uid
        batch.update(docRef, {
          'dosen_uid': newDosenUid,
        });
      }
    }

    try {
      await batch.commit();
      print('[UserService] Batch relasi berhasil: ${mahasiswaUids.length} mahasiswa');
    } catch (e) {
      print('gagal batch update: $e');
      throw Exception('Gagal memperbarui relasi dosen: $e');
    }
  }
}