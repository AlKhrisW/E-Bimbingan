import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

// Handler Background (Wajib Top Level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========================================================================
  // 1. INITIALIZATION
  // ========================================================================
  Future<void> initialize() async {
    // Request Permission (Hanya untuk keperluan token FCM, tidak ada pop-up lokal)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Listen Token Refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserService().saveDeviceToken(user.uid, newToken);
      }
    });
  }

  // ========================================================================
  // 2. FIRESTORE METHODS (Kirim & Baca)
  // ========================================================================

  /// Kirim notifikasi ke User Lain (Masuk Database untuk Halaman Notifikasi)
  Future<void> sendNotification({
    required String recipientUid,
    required String title,
    required String body,
    required String type,
    required String relatedId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'recipient_uid': recipientUid,
        'sender_uid': FirebaseAuth.instance.currentUser?.uid,
        'title': title,
        'body': body,
        'type': type,
        'related_id': relatedId,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Gagal kirim notifikasi: $e");
    }
  }

  /// Stream Notifikasi (Untuk didengarkan oleh UI Halaman Notifikasi)
  Stream<QuerySnapshot> getNotificationsStream(String recipientUid) {
    return _firestore
        .collection('notifications')
        .where('recipient_uid', isEqualTo: recipientUid)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  /// Tandai 1 notifikasi sudah dibaca
  Future<void> markAsRead(String docId) async {
    await _firestore.collection('notifications').doc(docId).update({'is_read': true});
  }

  /// Hapus notifikasi
  Future<void> deleteNotification(String docId) async {
    await _firestore.collection('notifications').doc(docId).delete();
  }

  /// Tandai SEMUA sudah dibaca
  Future<void> markAllAsRead(String recipientUid) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('notifications')
        .where('recipient_uid', isEqualTo: recipientUid)
        .where('is_read', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }
}