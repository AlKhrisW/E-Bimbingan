import 'package:ebimbingan/core/widgets/custom_badge_count.dart';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';

class DashboardPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String placement;
  final String? photoUrl;
  final VoidCallback onNotificationTap;
  final int notificationCount;

  const DashboardPageAppBar({
    super.key,
    required this.name,
    required this.placement,
    this.photoUrl,
    required this.onNotificationTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = name.isNotEmpty ? name.split(" ")[0] : "User";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "U";

    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      surfaceTintColor: AppTheme.backgroundColor,
      elevation: 0,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl!) : null,
                child: photoUrl == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Name & Placement
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$firstName 👋",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    placement,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Notification button
          IconButton(
            onPressed: onNotificationTap,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none, color: Colors.grey.shade900),
                
                Positioned(
                  right: -7,
                  top: -7,
                  child: CountBadge(
                    count: notificationCount,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}