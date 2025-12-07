import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔥 top section minimalist (no appbar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // divider subtil
            Container(
              height: 1,
              color: Colors.grey.shade300,
            ),

            // CONTENT
            Expanded(
              child: loading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : notifications.isEmpty
                  ? const Center(
                child: Text(
                  "No notifications yet",
                  style: TextStyle(
                      color: Colors.grey, fontSize: 16),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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
    );
  }

  Widget _notificationCard(NotificationItem n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: n.isSeen ? Colors.white : const Color(0xFFF0FFF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: n.isSeen ? Colors.grey.shade200 : const Color(0xFF2E8B57),
          width: n.isSeen ? 1 : 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            n.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            n.body,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            n.timeAgo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
