import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

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
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Channel standar
  final AndroidNotificationChannel _defaultChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'Notifikasi Aplikasi',
    description: 'Channel utama aplikasi',
    importance: Importance.max,
  );

  // Channel untuk Alarm/Reminder
  final AndroidNotificationChannel _reminderChannel = const AndroidNotificationChannel(
    'reminder_channel',
    'Pengingat Jadwal',
    description: 'Channel khusus pengingat',
    importance: Importance.high,
    playSound: true,
  );

  // ========================================================================
  // 1. INITIALIZATION
  // ========================================================================
  Future<void> initialize() async {
    // Init Timezone
    tz_data.initializeTimeZones();

    // Request Permission (iOS & Android 13+)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Init Local Notif Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Create Channels (Android)
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_defaultChannel);
    await platform?.createNotificationChannel(_reminderChannel);

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

  /// Kirim notifikasi ke User Lain (Masuk Database)
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

  /// Stream Notifikasi (Untuk didengarkan oleh UI)
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

  // ========================================================================
  // 3. LOCAL ALARM / REMINDER
  // ========================================================================

  /// Jadwalkan Alarm Lokal (Universal)
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      if (scheduledDate.isBefore(DateTime.now())) return;

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _reminderChannel.id,
            _reminderChannel.name,
            channelDescription: _reminderChannel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("Reminder dijadwalkan: $scheduledDate");
    } catch (e) {
      print("Gagal schedule reminder: $e");
    }
  }
}