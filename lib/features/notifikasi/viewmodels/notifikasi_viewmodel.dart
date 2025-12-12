// lib/features/notification/viewmodels/notification_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Utils & Services
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/services/notification_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';
import 'package:ebimbingan/data/services/user_service.dart'; // [PENTING] Tambah ini

// Models
import 'package:ebimbingan/data/models/notification_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';

class NotificationViewModel extends ChangeNotifier {
  // --- DEPENDENCIES ---
  final NotificationService _notifService = NotificationService();
  final AjuanBimbinganService _ajuanService = AjuanBimbinganService();
  final LogBimbinganService _logService = LogBimbinganService();
  final UserService _userService = UserService(); // [PENTING] Service User

  // =================================================================
  // GETTERS (STREAM)
  // =================================================================
  
  Stream<QuerySnapshot> get notificationStream {
    final uid = AuthUtils().currentUid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _notifService.getNotificationsStream(uid);
  }

  /// Stream khusus untuk menghitung jumlah notifikasi yang belum dibaca (badge)
  Stream<int> get unreadCountStream {
    return notificationStream.map((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['is_read'] == false) {
          count++;
        }
      }
      return count;
    });
  }

  // =================================================================
  // BASIC ACTIONS
  // =================================================================

  Future<void> markAsRead(String docId) async {
    await _notifService.markAsRead(docId);
  }

  Future<void> deleteNotification(String docId) async {
    await _notifService.deleteNotification(docId);
  }

  Future<void> markAllAsRead() async {
    final uid = AuthUtils().currentUid;
    if (uid != null) {
      await _notifService.markAllAsRead(uid);
    }
  }

  // =================================================================
  // SMART NAVIGATION LOGIC
  // =================================================================

  Future<void> handleNotificationTap(BuildContext context, NotificationModel notif) async {
    // 1. Tandai dibaca
    if (!notif.isRead) {
      _notifService.markAsRead(notif.id);
    }

    // 2. Loading...
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 3. Cek Role User Saat Ini
      final uid = AuthUtils().currentUid;
      if (uid == null) throw Exception("User tidak terlogin");
      
      final user = await _userService.fetchUserByUid(uid);
      final isMahasiswa = user.role == 'mahasiswa'; // Asumsi string role

      String routeName = '';
      Object? arguments;

      switch (notif.type) {
        // -----------------------------------------------------------
        // KASUS 1: AJUAN BIMBINGAN
        // -----------------------------------------------------------
        case 'ajuan':
        case 'ajuan_status':
        case 'info_jadwal':
        case 'reminder':
        case 'ajuan_masuk':

          final ajuan = await _ajuanService.getAjuanByUid(notif.relatedId);
          
          if (ajuan != null) {
            arguments = notif.relatedId; // Kirim ID saja (String)

            if (isMahasiswa) {
              // --- ROUTE KHUSUS MAHASISWA ---
              // Arahkan ke screen detail mahasiswa yang sudah diperbaiki sebelumnya
              routeName = '/mahasiswa_detail_ajuan'; 
            } else {
              // --- ROUTE KHUSUS DOSEN ---
              if (ajuan.status == AjuanStatus.proses) {
                routeName = '/detail_ajuan_validasi'; 
              } else {
                routeName = '/detail_ajuan_riwayat';
              }
            }
          }
          break;

        // -----------------------------------------------------------
        // KASUS 2: LOG MINGGUAN (Bimbingan)
        // -----------------------------------------------------------
        case 'log_bimbingan':
        case 'log_status':
        case 'log_mingguan_update':

          final log = await _logService.getLogBimbinganByUid(notif.relatedId);
          if (log != null) {
            arguments = notif.relatedId; // Kirim ID saja (String)

            if (isMahasiswa) {
              // --- ROUTE KHUSUS MAHASISWA ---
              if (log.status == LogBimbinganStatus.rejected || log.status == LogBimbinganStatus.draft) {
                routeName = '/mahasiswa_update_log_mingguan';
              } else {
                routeName = '/mahasiswa_detail_log_mingguan';
              }
            } else {
              // --- ROUTE KHUSUS DOSEN ---
              if (log.status == LogBimbinganStatus.pending || log.status == LogBimbinganStatus.draft) {
                routeName = '/detail_log_validasi';
              } else {
                routeName = '/detail_log_riwayat';
              }
            }
          }
          break;

        // -----------------------------------------------------------
        // KASUS 3: LOGBOOK HARIAN
        // -----------------------------------------------------------
        case 'logbook_harian':
        case 'log_harian_baru':

          arguments = notif.relatedId;

          if (isMahasiswa) {
             routeName = '/mahasiswa_detail_log_harian';
          } else {
             // Dosen biasanya melihat di rekap, tapi jika ada detail khusus:
             routeName = '/dosen_detail_log_harian';
          }
          break;

        default:
          print("Tipe notifikasi tidak dikenal: ${notif.type}");
      }

      // 4. Navigasi
      if (context.mounted) {
        Navigator.pop(context); // Tutup loading

        if (routeName.isNotEmpty) {
          debugPrint("Navigating to: $routeName with args: $arguments");
          Navigator.pushNamed(context, routeName, arguments: arguments);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data terkait tidak ditemukan/terhapus")),
          );
        }
      }

    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }
}