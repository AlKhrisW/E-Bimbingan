// lib/features/notification/viewmodels/notification_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Utils & Services
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/services/notification_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';

// Models
import 'package:ebimbingan/data/models/notification_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';

class NotificationViewModel extends ChangeNotifier {
  // --- DEPENDENCIES ---
  final NotificationService _notifService = NotificationService();
  
  // Service tambahan untuk pengecekan status data sebelum navigasi
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final LogBimbinganService _logService = LogBimbinganService();

  // =================================================================
  // GETTERS (STREAM)
  // =================================================================
  
  /// Mengambil stream notifikasi real-time khusus user yang login
  Stream<QuerySnapshot> get notificationStream {
    final uid = AuthUtils.currentUid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _notifService.getNotificationsStream(uid);
  }

  // =================================================================
  // BASIC ACTIONS (Baca & Hapus)
  // =================================================================

  Future<void> markAsRead(String docId) async {
    await _notifService.markAsRead(docId);
  }

  Future<void> deleteNotification(String docId) async {
    await _notifService.deleteNotification(docId);
  }

  Future<void> markAllAsRead() async {
    final uid = AuthUtils.currentUid;
    if (uid != null) {
      await _notifService.markAllAsRead(uid);
    }
  }

  // =================================================================
  // SMART NAVIGATION LOGIC (Fitur Utama)
  // =================================================================

  /// Menangani klik pada notifikasi:
  /// 1. Tandai sudah dibaca
  /// 2. Cek status data di server (Loading...)
  /// 3. Arahkan ke halaman Validasi (jika butuh aksi) atau Riwayat (jika sudah selesai)
  Future<void> handleNotificationTap(BuildContext context, NotificationModel notif) async {
    // 1. Tandai dibaca di background (Fire and Forget)
    if (!notif.isRead) {
      _notifService.markAsRead(notif.id);
    }

    // 2. Tampilkan Loading Indicator (karena kita harus fetch data dulu)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String routeName = '';
      Object? arguments;

      switch (notif.type) {
        // -----------------------------------------------------------
        // KASUS 1: AJUAN BIMBINGAN (Judul/Jadwal)
        // -----------------------------------------------------------
        case 'ajuan':
        case 'ajuan_status':
        case 'info_jadwal':
        case 'reminder':
          // Fetch data ajuan terbaru dari server
          final ajuan = await _ajuanService.getAjuanByUid(notif.relatedId);
          
          if (ajuan != null) {
            arguments = notif.relatedId;

            if (ajuan.status == AjuanStatus.proses) {
              routeName = '/detail_ajuan_validasi'; 
            } else {
              routeName = '/detail_ajuan_riwayat';
            }
          }
          break;

        // -----------------------------------------------------------
        // KASUS 2: LOG BIMBINGAN (Mingguan)
        // -----------------------------------------------------------
        case 'log_bimbingan':
        case 'log_status':
          final log = await _logService.getLogBimbinganByUid(notif.relatedId);
          if (log != null) {
            arguments = notif.relatedId;
            // Jika status PENDING/DRAFT -> Masuk halaman Validasi
            if (log.status == LogBimbinganStatus.pending || log.status == LogBimbinganStatus.draft) {
              routeName = '/detail_log_validasi';
            } else {
              routeName = '/detail_log_riwayat';
            }
          }
          break;

        // -----------------------------------------------------------
        // KASUS 3: LOGBOOK HARIAN (Tidak ada validasi khusus)
        // -----------------------------------------------------------
        case 'logbook_harian':
          routeName = '/detail_logbook_harian';
          arguments = notif.relatedId;
          break;

        default:
          print("Tipe notifikasi tidak dikenal: ${notif.type}");
      }

      // 3. Tutup Loading & Lakukan Navigasi
      if (context.mounted) {
        Navigator.pop(context); // Tutup dialog loading

        if (routeName.isNotEmpty) {
          Navigator.pushNamed(context, routeName, arguments: arguments);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data terkait tidak ditemukan atau telah dihapus")),
          );
        }
      }

    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Tutup loading jika error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }
}