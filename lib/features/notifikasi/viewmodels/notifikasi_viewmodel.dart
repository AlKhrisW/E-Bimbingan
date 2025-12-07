import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/services/notification_service.dart';
import 'package:ebimbingan/data/models/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  // Stream Data
  Stream<QuerySnapshot> get notificationStream {
    final uid = AuthUtils.currentUid;
    if (uid == null) return const Stream.empty();
    return _service.getNotificationsStream(uid);
  }

  // Aksi Dasar
  Future<void> deleteNotification(String id) async => await _service.deleteNotification(id);
  
  Future<void> markAllAsRead() async {
    final uid = AuthUtils.currentUid;
    if (uid != null) await _service.markAllAsRead(uid);
  }

  // =================================================================
  // UNIVERSAL NAVIGATION LOGIC
  // =================================================================
  void handleNotificationTap(BuildContext context, NotificationModel notif) {
    // 1. Tandai dibaca di background
    if (!notif.isRead) {
      _service.markAsRead(notif.id);
    }

    // 2. Tentukan Tujuan Berdasarkan Tipe
    // Logic ini berlaku untuk Dosen MAUPUN Mahasiswa
    switch (notif.type) {
      
      // Kasus: Ajuan Bimbingan (Status berubah atau Ajuan baru masuk)
      case 'ajuan':
      case 'ajuan_status':
      case 'info_jadwal':
      case 'reminder': // Alarm H-1
        Navigator.pushNamed(
          context,
          '/detail_ajuan', // Pastikan route ini ada di main.dart
          arguments: notif.relatedId, // Kirim ID Ajuan
        );
        break;

      // Kasus: Log Bimbingan
      case 'log_bimbingan':
      case 'log_status':
        Navigator.pushNamed(
          context,
          '/detail_log', // Pastikan route ini ada di main.dart
          arguments: notif.relatedId, // Kirim ID Log
        );
        break;

      default:
        // Fallback jika tipe tidak dikenal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Info: ${notif.body}")),
        );
    }
  }
}