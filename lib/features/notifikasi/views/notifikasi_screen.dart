import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notifikasi_viewmodel.dart';
import '../widgets/custom_notification_appbar.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebimbingan/data/models/notification_model.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(),
      child: Scaffold(
        // Panggil Custom AppBar di sini
        appBar: const CustomNotificationAppBar(),
        
        body: Consumer<NotificationViewModel>(
          builder: (context, vm, _) {
            return StreamBuilder<QuerySnapshot>(
              stream: vm.notificationStream,
              builder: (context, snapshot) {
                // ... (Logika body tetap sama seperti sebelumnya) ...
                
                // 1. Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Error
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                // 3. Kosong
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final docs = snapshot.data!.docs;

                // 4. List Data
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final notif = NotificationModel.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id);

                    return Dismissible(
                      key: Key(notif.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Hapus Notifikasi?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Hapus",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) {
                        vm.deleteNotification(notif.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Dihapus")));
                      },
                      child: ListTile(
                        leading: _buildIcon(notif.type, notif.isRead),
                        title: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM HH:mm').format(notif.createdAt),
                              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        tileColor: notif.isRead ? null : Colors.blue.withOpacity(0.05),
                        onTap: () => vm.handleNotificationTap(context, notif),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

   Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined, 
            size: 60, 
            color: Colors.grey[300]
          ),
          const SizedBox(height: 16),
          Text(
            "Tidak ada notifikasi",
            style: const TextStyle(
              fontSize: 16, 
              color: Colors.grey, 
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.center,
          ),
        ]
      ),
    );
  }

  Widget _buildIcon(String type, bool isRead) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'ajuan':
      case 'ajuan_status':
        iconData = Icons.assignment;
        color = Colors.orange;
        break;
      case 'log_bimbingan':
      case 'log_status':
        iconData = Icons.history_edu;
        color = Colors.blue;
        break;
      case 'reminder':
        iconData = Icons.alarm;
        color = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: isRead ? Colors.grey[200] : color.withOpacity(0.1),
      child: Icon(iconData, color: isRead ? Colors.grey : color),
    );
  }
}