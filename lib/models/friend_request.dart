class FriendRequest {
  final String id;
  final String requesterId;
  final String requesterUsername;
  final String addresseeId;
  final String addresseeUsername;
  final String status;
  final String? message;
  final String createdAt;
  final String? respondedAt;

  FriendRequest({
    required this.id,
    required this.requesterId,
    required this.requesterUsername,
    required this.addresseeId,
    required this.addresseeUsername,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json["id"],
      requesterId: json["requesterId"],
      requesterUsername: json["requesterUsername"],
      addresseeId: json["addresseeId"],
      addresseeUsername: json["addresseeUsername"],
      status: json["status"],
      message: json["message"],
      createdAt: json["createdAt"],
      respondedAt: json["respondedAt"],
    );
  }
}
