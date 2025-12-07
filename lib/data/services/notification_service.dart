import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz; 
import 'package:timezone/data/latest.dart' as tz_data;
import 'user_service.dart';

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

  final AndroidNotificationChannel _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'Notifikasi Penting',
    description: 'Channel ini digunakan untuk notifikasi penting',
    importance: Importance.max,
  );

  final AndroidNotificationChannel _reminderChannel = const AndroidNotificationChannel(
    'reminder_channel',
    'Pengingat Jadwal',
    description: 'Channel ini untuk alarm pengingat bimbingan',
    importance: Importance.high,
    playSound: true,
  );

  Future<void> initialize() async {
    // --- 1. Init Timezone (Gunakan alias baru tz_data) ---
    tz_data.initializeTimeZones();

    // 2. Request Permission
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // 3. Init Local Notification
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Tambahkan setting iOS agar aman (opsional)
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle jika notifikasi diklik di sini
        print("Notifikasi diklik: ${details.payload}");
      },
    );

    // 4. Create Channels
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
    await platform?.createNotificationChannel(_reminderChannel);

    // 5. Setup Listeners
    _messaging.onTokenRefresh.listen((newToken) async {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await UserService().saveDeviceToken(currentUser.uid, newToken);
      }
    });
  }

  // A. KIRIM NOTIFIKASI KE MAHASISWA
  Future<void> notifyMahasiswa({
    required String mahasiswaUid,
    required String title,
    required String body,
    required String type,
    required String relatedId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'recipient_uid': mahasiswaUid,
        'sender_uid': FirebaseAuth.instance.currentUser?.uid,
        'title': title,
        'body': body,
        'type': type,
        'related_id': relatedId,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
      print("[NotificationService] Notifikasi dikirim ke database mahasiswa: $mahasiswaUid");
    } catch (e) {
      print("[NotificationService] Gagal kirim notifikasi database: $e");
    }
  }

  // B. JADWALKAN PENGINGAT H-1
  Future<void> scheduleDosenReminder({
    required int id,
    required String title,
    required String body,
    required DateTime jadwalBimbingan,
  }) async {
    try {
      final scheduledDate = jadwalBimbingan.subtract(const Duration(days: 1));

      if (scheduledDate.isBefore(DateTime.now())) {
        print("[NotificationService] Waktu H-1 sudah lewat.");
        return;
      }

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        // Gunakan alias 'tz' untuk TZDateTime
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

      print("[NotificationService] Pengingat H-1 dijadwalkan: $scheduledDate");
    } catch (e) {
      print("[NotificationService] Gagal menjadwalkan reminder: $e");
    }
  }
}