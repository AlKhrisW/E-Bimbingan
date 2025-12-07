import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'ajuan', 'log_bimbingan', 'log_harian', 'reminder'
  final String recipientUid; // UID penerima (Dosen atau Mahasiswa)
  final String relatedId; // ID dokumen terkait (misal: ID proposal, ID log)
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.recipientUid,
    required this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'recipient_uid': recipientUid,
      'related_id': relatedId,
      'is_read': isRead,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> data, String docId) {
    return NotificationModel(
      id: docId,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'info',
      recipientUid: data['recipient_uid'] ?? '',
      relatedId: data['related_id'] ?? '',
      isRead: data['is_read'] ?? false,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}