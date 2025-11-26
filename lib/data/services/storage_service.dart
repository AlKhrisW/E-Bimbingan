// lib/data/services/storage_service.dart
// VERSI BASE64 - TANPA FIREBASE STORAGE (GRATIS!)

import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  // ========================================================================
  // IMAGE PICKER
  // ========================================================================

  /// Pick image dari galeri
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // resize image
        maxHeight: 800,
        imageQuality: 70, // compress image
      );
      
      if (image != null) {
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      print('❌ Error picking image: $e');
      return null;
    }
  }

  /// Pick image dari kamera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (image != null) {
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      print('❌ Error taking photo: $e');
      return null;
    }
  }


  // base64 methods

  /// convert image file ke base64 string
  Future<String?> imageToBase64(File imageFile) async {
    try {
      print('🔄 Converting image to Base64...');
      
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();
      
      // Convert to Base64
      final base64String = base64Encode(bytes);
      
      // Cek ukuran (max 500KB untuk safety)
      final sizeInKB = base64String.length / 1024;
      print('📊 Base64 size: ${sizeInKB.toStringAsFixed(2)} KB');
      
      if (sizeInKB > 500) {
        print('⚠️ Warning: Image size > 500KB, might hit Firestore limit');
        throw 'Ukuran foto terlalu besar. Maksimal 500KB.\nSilakan pilih foto yang lebih kecil.';
      }
      
      print('✅ Base64 conversion success');
      return base64String;
      
    } catch (e) {
      print('❌ Error converting to Base64: $e');
      rethrow;
    }
  }

  /// Convert Base64 string ke Uint8List (untuk display)
  Uint8List? base64ToImage(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('❌ Error decoding Base64: $e');
      return null;
    }
  }

//  file validation

  /// validasi ukuran file (max 2MB sebelum convert)
  bool isFileSizeValid(File file, {int maxSizeInMB = 2}) {
    try {
      final fileSizeInBytes = file.lengthSync();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      print('📊 File size: ${fileSizeInMB.toStringAsFixed(2)} MB');
      
      return fileSizeInMB <= maxSizeInMB;
    } catch (e) {
      print('❌ Error checking file size: $e');
      return false;
    }
  }

  /// validasi extension file
  bool isImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Get file size in KB
  double getFileSizeInKB(File file) {
    try {
      final bytes = file.lengthSync();
      return bytes / 1024;
    } catch (e) {
      return 0;
    }
  }

  /// Get file size in MB
  double getFileSizeInMB(File file) {
    try {
      final bytes = file.lengthSync();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0;
    }
  }
}