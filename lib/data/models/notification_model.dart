import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; 
  final String recipientUid; 
  final String relatedId;
  final String? senderUid;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.recipientUid,
    required this.relatedId,
    this.senderUid,
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
      'sender_uid': senderUid, 
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
      senderUid: data['sender_uid'],
      isRead: data['is_read'] ?? false,
      createdAt: _parseTimestamp(data['created_at']),
    );
  }

  static DateTime _parseTimestamp(dynamic val) {
    if (val is Timestamp) return val.toDate();
    return DateTime.now();
  }
}