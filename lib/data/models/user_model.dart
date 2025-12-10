import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // Core Fields
  final String uid;
  final String name;
  final String email;
  final String role;
  
  // Optional Fields
  final String? photoBase64;
  final String? phoneNumber;
  final String? fcmToken;

  // Mahasiswa Specific
  final String? dosenUid;
  final String? nim;
  final String? placement;
  final DateTime? startDate;
  final String? programStudi;

  // Dosen Specific
  final String? nip;
  final String? jabatan;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoBase64,
    this.phoneNumber,
    this.fcmToken,
    this.dosenUid,
    this.nim,
    this.placement,
    this.startDate,
    this.programStudi,
    this.nip,
    this.jabatan,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? '',
      role: data['role'] ?? 'unknown',
      
      // Global optionals
      photoBase64: data['photo_base64'],
      phoneNumber: data['phone_number'],
      fcmToken: data['fcm_token'],
      
      // Mahasiswa fields
      dosenUid: data['dosen_uid'],
      nim: data['nim'],
      placement: data['placement'],
      startDate: _parseTimestamp(data['start_date']),
      programStudi: data['program_studi'],
      
      // Dosen fields
      nip: data['nip'],
      jabatan: data['jabatan'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,

      // Global fields (hanya simpan jika tidak null)
      if (photoBase64 != null) 'photo_base64': photoBase64,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (fcmToken != null) 'fcm_token': fcmToken,
      // Mahasiswa specific
      if (role == 'mahasiswa') ...{
        'dosen_uid': dosenUid,
        'nim': nim,
        'placement': placement,
        'program_studi': programStudi,
        if (startDate != null) 'start_date': Timestamp.fromDate(startDate!),
      },

      // Dosen specific
      if (role == 'dosen') ...{
        'nip': nip,
        'jabatan': jabatan,
      },
    };
  }

  // Helper untuk parsing tanggal yang aman
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    try {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
    } catch (e) {
      print('Warning: Error parsing timestamp: $e');
    }
    return null;
  }

  // ========================================================================
  // GETTERS & HELPERS (DIKEMBALIKAN)
  // ========================================================================

  String get displayName => name;

  bool get isAdmin => role == 'admin';
  bool get isDosen => role == 'dosen';
  bool get isMahasiswa => role == 'mahasiswa';

  String get roleLabel {
    switch (role) {
      case 'admin': return 'Administrator';
      case 'dosen': return 'Dosen Pembimbing';
      case 'mahasiswa': return 'Mahasiswa';
      default: return role;
    }
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? photoBase64,
    String? phoneNumber,
    String? fcmToken,
    String? dosenUid,
    String? nim,
    String? placement,
    DateTime? startDate,
    String? nip,
    String? jabatan,
    String? programStudi,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoBase64: photoBase64 ?? this.photoBase64,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      dosenUid: dosenUid ?? this.dosenUid,
      nim: nim ?? this.nim,
      placement: placement ?? this.placement,
      startDate: startDate ?? this.startDate,
      nip: nip ?? this.nip,
      jabatan: jabatan ?? this.jabatan,
      programStudi: programStudi ?? this.programStudi,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, role: $role, fcmToken: $fcmToken)';
  }
}