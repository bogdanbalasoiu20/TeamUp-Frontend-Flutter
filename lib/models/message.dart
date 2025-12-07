class ChatMessage {
  final String id;
  final String matchId;
  final String senderId;
  final String senderUsername;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.senderUsername,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawDate = json["createdAt"];

    return ChatMessage(
      id: json["id"],
      matchId: json["matchId"],
      senderId: json["senderId"],
      senderUsername: json["senderUsername"],
      content: json["content"],
      createdAt: rawDate == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.parse(rawDate),
    );
  }
}
