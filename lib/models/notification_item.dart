class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? payload;
  bool isSeen;
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
    this.seenAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json["id"],
      type: json["type"],
      title: json["title"],
      body: json["body"],
      payload: json["payload"] is Map ? json["payload"] : null,
      isSeen: json["isSeen"],
      createdAt: DateTime.parse(json["createdAt"]),
      seenAt: json["seenAt"] != null ? DateTime.parse(json["seenAt"]) : null,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return "just now";
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inDays < 1) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  String? get matchId {
    final value = payload?['matchId'];
    return value?.toString();
  }
}
