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

  // ========================================================================
  // PHOTO PROFILE METHODS (BASE64 VERSION)
  // ========================================================================

  /// Update foto profil user (simpan sebagai Base64 di Firestore)
  Future<bool> updateProfilePhoto(String uid, File imageFile) async {
    try {
      print('🔄 [UserService] Starting photo update for UID: $uid');

      // Step 1: Validasi format file
      if (!_storageService.isImageFile(imageFile)) {
        throw 'File harus berupa gambar (jpg, png, gif, webp)';
      }

      // Step 2: Validasi ukuran file (max 2MB sebelum convert)
      if (!_storageService.isFileSizeValid(imageFile, maxSizeInMB: 2)) {
        throw 'Ukuran file maksimal 2MB';
      }

      // Step 3: Convert image ke Base64
      print('🔄 [UserService] Converting to Base64...');
      final base64String = await _storageService.imageToBase64(imageFile);
      
      if (base64String == null || base64String.isEmpty) {
        throw 'Gagal mengkonversi foto';
      }

      print('✅ [UserService] Base64 conversion success');

      // Step 4: Update Firestore dengan Base64 string
      await _users.doc(uid).update({
        'photo_base64': base64String, // 👈 SIMPAN BASE64 DI FIRESTORE
      });

      print('✅ [UserService] Firestore updated successfully');
      return true;

    } on FirebaseException catch (e) {
      print('❌ [UserService] Firebase error: ${e.code} - ${e.message}');
      throw 'Error Firebase: ${e.message ?? 'Terjadi kesalahan'}';
      
    } on SocketException catch (e) {
      print('❌ [UserService] Network error: $e');
      throw 'Tidak ada koneksi internet';
      
    } catch (e) {
      print('❌ [UserService] Unexpected error: $e');
      rethrow;
    }
  }

  /// Hapus foto profil user
  Future<bool> removeProfilePhoto(String uid) async {
    try {
      print('🗑️ [UserService] Removing photo for UID: $uid');

      // Hapus field 'photo_base64' dari Firestore
      await _users.doc(uid).update({
        'photo_base64': FieldValue.delete(),
      });

      print('✅ [UserService] Photo removed successfully');
      return true;

    } on FirebaseException catch (e) {
      print('❌ [UserService] Firebase error: ${e.code} - ${e.message}');
      throw 'Error Firebase: ${e.message ?? 'Terjadi kesalahan'}';
      
    } catch (e) {
      print('❌ [UserService] Unexpected error: $e');
      rethrow;
    }
  }

  /// Get foto profil Base64 dari Firestore
  Future<String?> getProfilePhotoBase64(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      
      if (!doc.exists) {
        print('⚠️ [UserService] User $uid not found');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>?;
      final photoBase64 = data?['photo_base64'] as String?;
      
      if (photoBase64 != null && photoBase64.isNotEmpty) {
        print('📷 [UserService] Photo Base64 found for $uid');
      } else {
        print('📷 [UserService] No photo for $uid');
      }
      
      return photoBase64;

    } catch (e) {
      print('❌ [UserService] Error getting photo: $e');
      return null;
    }
  }

  /// Check apakah user memiliki foto profil
  Future<bool> hasProfilePhoto(String uid) async {
    try {
      final photoBase64 = await getProfilePhotoBase64(uid);
      return photoBase64 != null && photoBase64.isNotEmpty;
    } catch (e) {
      print('❌ [UserService] Error checking photo: $e');
      return false;
    }
  }
}