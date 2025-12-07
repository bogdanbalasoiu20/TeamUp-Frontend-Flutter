class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? payload;
  final bool isSeen;
  final DateTime createdAt;
  final DateTime? seenAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.payload,
    required this.isSeen,
    required this.createdAt,
    required this.seenAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json["id"],
      type: json["type"],
      title: json["title"] ?? "",
      body: json["body"] ?? "",
      payload: json["payload"],
      isSeen: json["isSeen"] ?? false,
      createdAt: DateTime.parse(json["createdAt"]),
      seenAt: json["seenAt"] != null
          ? DateTime.parse(json["seenAt"])
          : null,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";

    return "${createdAt.day}/${createdAt.month}";
  }
}
