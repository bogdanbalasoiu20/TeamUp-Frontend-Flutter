class FriendRequest {
  final String id;
  final String requesterId;
  final String requesterUsername;
  final String addresseeId;
  final String addresseeUsername;
  final String status;
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;

  FriendRequest({
    required this.id,
    required this.requesterId,
    required this.requesterUsername,
    required this.addresseeId,
    required this.addresseeUsername,
    required this.status,
    required this.message,
    required this.createdAt,
    required this.respondedAt,
  });

  String otherUsername(String myUserId) {
    return myUserId == requesterId ? addresseeUsername : requesterUsername;
  }

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json["id"],
      requesterId: json["requesterId"],
      requesterUsername: json["requesterUsername"],
      addresseeId: json["addresseeId"],
      addresseeUsername: json["addresseeUsername"],
      status: json["status"],
      message: json["message"],
      createdAt: DateTime.parse(json["createdAt"]),
      respondedAt: json["respondedAt"] != null
          ? DateTime.parse(json["respondedAt"])
          : null,
    );
  }
}
