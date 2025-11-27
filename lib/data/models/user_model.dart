import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? photoBase64; // new field for profile photo

  // Mahasiswa fields
  final String? dosenUid;
  final String? nim;
  final String? placement;
  final DateTime? startDate;
  final String? programStudi; // HANYA UNTUK MAHASISWA

  // Dosen fields
  final String? nip;
  final String? jabatan;

  // Global fields
  final String? phoneNumber;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoBase64,
    this.dosenUid,
    this.nim,
    this.placement,
    this.startDate,
    this.programStudi,
    this.nip,
    this.jabatan,
    this.phoneNumber,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? '',
      role: data['role'] ?? 'unknown',
      photoBase64: data['photo_base64'],
      dosenUid: data['dosen_uid'],
      nim: data['nim'],
      placement: data['placement'],
      startDate: _parseTimestamp(data['start_date']),
      programStudi: data['program_studi'],
      nip: data['nip'],
      jabatan: data['jabatan'],
      phoneNumber: data['phone_number'],
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
    } catch (e) {
      print('Warning: Error parsing timestamp: $e');
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,

      // Global fields
      if (photoBase64 != null) 'photo_base64': photoBase64,
      if (phoneNumber != null) 'phone_number': phoneNumber,

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

  String get displayName => name;

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

  bool get isAdmin => role == 'admin';
  bool get isDosen => role == 'dosen';
  bool get isMahasiswa => role == 'mahasiswa';

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? photoBase64,
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
      photoBase64: photoBase64 ?? this.photoBase64,
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