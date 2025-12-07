import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ebimbingan/data/models/notification_model.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return const Scaffold(body: Center(child: Text("Login required")));

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: StreamBuilder<QuerySnapshot>(
        // Query notifikasi khusus untuk user yang sedang login
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipient_uid', isEqualTo: currentUser.uid)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada notifikasi"));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final notif = NotificationModel.fromMap(data, docs[index].id);

              return ListTile(
                leading: _buildIcon(notif.type),
                title: Text(
                  notif.title,
                  style: TextStyle(
                    fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif.body),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM HH:mm').format(notif.createdAt),
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                tileColor: notif.isRead ? null : Colors.blue.withOpacity(0.05),
                onTap: () {
                  // Tandai sudah dibaca
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notif.id)
                      .update({'is_read': true});

                  // Navigasi sesuai konteks
                  _handleNavigation(context, notif);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Icon dinamis sesuai tipe notifikasi
  Widget _buildIcon(String type) {
    switch (type) {
      case 'ajuan':
        return const Icon(Icons.file_copy, color: Colors.orange);
      case 'log_bimbingan':
        return const Icon(Icons.history_edu, color: Colors.blue);
      case 'log_harian':
        return const Icon(Icons.book, color: Colors.green);
      case 'reminder':
        return const Icon(Icons.alarm, color: Colors.red);
      default:
        return const Icon(Icons.notifications);
    }
  }

  // Navigasi saat notifikasi diklik
  void _handleNavigation(BuildContext context, NotificationModel notif) {
    // Contoh logika navigasi
    if (notif.type == 'ajuan') {
      // Navigator.pushNamed(context, '/detail_ajuan', arguments: notif.relatedId);
    } else if (notif.type == 'reminder') {
      // Navigator.pushNamed(context, '/jadwal');
    }
  }
}