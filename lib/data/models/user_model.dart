// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin', 'dosen', atau 'mahasiswa'
  
  // Mahasiswa fields
  final String? dosenUid; 
  final String? nim;
  final String? placement;
  final DateTime? startDate; 
  
  // Dosen fields
  final String? nip;
  final String? jabatan; 
  
  // Global fields (semua role bisa punya)
  final String? programStudi; 
  final String? phoneNumber;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.dosenUid,
    this.nim,
    this.placement,
    this.startDate,
    this.nip,
    this.jabatan,
    this.programStudi,
    this.phoneNumber,
  });

  /// Parse data dari Firestore ke Model
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? '',
      role: data['role'] ?? 'unknown',
      
      // Mahasiswa fields
      dosenUid: data['dosen_uid'], 
      nim: data['nim'],
      placement: data['placement'],
      startDate: _parseTimestamp(data['start_date']),
      
      // Dosen fields
      nip: data['nip'],
      jabatan: data['jabatan'],
      
      // Global fields (FIX: tambahkan parsing)
      programStudi: data['program_studi'],
      phoneNumber: data['phone_number'],
    );
  }

  /// Helper: Parse Timestamp dengan aman
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    
    try {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
    } catch (e) {
      print('⚠️ Error parsing timestamp: $e');
    }
    
    return null;
  }

  /// Convert Model ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      
      // Global fields (semua role)
      if (programStudi != null) 'program_studi': programStudi,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      
      // Mahasiswa specific
      if (role == 'mahasiswa') ...{
        if (dosenUid != null) 'dosen_uid': dosenUid,
        if (nim != null) 'nim': nim,
        if (placement != null) 'placement': placement,
        if (startDate != null) 'start_date': Timestamp.fromDate(startDate!),
      },
      
      // Dosen specific
      if (role == 'dosen') ...{
        if (nip != null) 'nip': nip,
        if (jabatan != null) 'jabatan': jabatan,
      },
    };
  }

  /// Helper: Display name untuk UI
  String get displayName => name;

  /// Helper: Role label untuk UI
  String get roleLabel {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'dosen':
        return 'Dosen Pembimbing';
      case 'mahasiswa':
        return 'Mahasiswa';
      default:
        return role;
    }
  }

  /// Helper: Check apakah user adalah admin
  bool get isAdmin => role == 'admin';

  /// Helper: Check apakah user adalah dosen
  bool get isDosen => role == 'dosen';

  /// Helper: Check apakah user adalah mahasiswa
  bool get isMahasiswa => role == 'mahasiswa';

  /// CopyWith untuk update data
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? dosenUid,
    String? nim,
    String? placement,
    DateTime? startDate,
    String? nip,
    String? jabatan,
    String? programStudi,
    String? phoneNumber,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      dosenUid: dosenUid ?? this.dosenUid,
      nim: nim ?? this.nim,
      placement: placement ?? this.placement,
      startDate: startDate ?? this.startDate,
      nip: nip ?? this.nip,
      jabatan: jabatan ?? this.jabatan,
      programStudi: programStudi ?? this.programStudi,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, role: $role)';
  }
}