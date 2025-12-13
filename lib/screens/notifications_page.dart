import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/friends/friends_home_page.dart';
import 'package:team_up_fe_new/screens/match_participants_page.dart';
import '../services/notifications_api.dart';
import '../models/notification_item.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await NotificationsApi.fetchAll();
    setState(() {
      notifications = list;
      loading = false;
    });
  }

  // -------------------------------
  // REDIRECT FUNCTION
  // -------------------------------
  void _handleNotificationTap(NotificationItem n) async {
    // mark as seen
    if (!n.isSeen) {
      await NotificationsApi.markAsSeen(n.id);
      setState(() => n.isSeen = true);
    }

    switch (n.type) {
      case "FRIEND_REQUEST_RECEIVED":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FriendsHomePage(initialTab: 2),
          ),
        );
        break;

      case "FRIEND_REQUEST_ACCEPTED":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FriendsHomePage(initialTab: 0),
          ),
        );
        break;


      case "JOIN_REQUEST_RECEIVED":
      case "JOIN_REQUEST_ACCEPTED":
      case "JOIN_WAITLIST":
      case "PROMOTED_FROM_WAITLIST":
      case "MOVED_TO_WAITLIST":
      case "MATCH_LEFT":
      case "MATCH_INVITE_RECEIVED":
      case "MATCH_INVITE_ACCEPTED":
      case "MATCH_UPDATED":
      case "MATCH_STARTING_SOON":
      case "MATCH_CANCELLED":
         if (n.matchId != null) {
           Navigator.push(
             context,
             MaterialPageRoute(
               builder: (_) => MatchOverviewPage(matchId: n.matchId!),
             ),
           );
         }
         break;

       default:
         print("Unhandled notification type: ${n.type}");
    }
  }

  // -------------------------------
  // ICONS BASED ON TYPE
  // -------------------------------
  IconData _iconFor(NotificationItem n) {
    switch (n.type) {
      case "FRIEND_REQUEST_RECEIVED":
        return Icons.person_add_alt_1;
      case "FRIEND_REQUEST_ACCEPTED":
        return Icons.check_circle_outline;
      case "MATCH_INVITE_RECEIVED":
        return Icons.sports_soccer;
      case "MATCH_INVITE_ACCEPTED":
        return Icons.handshake;
      case "MATCH_UPDATED":
        return Icons.edit_note;
      case "MATCH_CANCELLED":
        return Icons.cancel_outlined;
      case "MATCH_STARTING_SOON":
        return Icons.access_time_filled_rounded;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF003B2F),
            Color(0xFF0A6F4A),
            Color(0xFF062D24),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 22, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // BODY
              Expanded(
                child: loading
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : notifications.isEmpty
                    ? const Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return _notificationCard(n);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // NOTIFICATION CARD UI
  // -------------------------------
  Widget _notificationCard(NotificationItem n) {
    final icon = _iconFor(n);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleNotificationTap(n),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.isSeen
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.isSeen
                ? Colors.white.withOpacity(0.25)
                : const Color(0xFF46C264),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),

            const SizedBox(width: 14),

            // TEXTS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),

            if (!n.isSeen)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF46C264),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "NEW",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
