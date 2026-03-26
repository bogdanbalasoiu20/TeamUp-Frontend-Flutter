class InvitableFriend {
  final String userId;
  final String username;
  final bool invited;
  final String? photoUrl;

  InvitableFriend({
    required this.userId,
    required this.username,
    required this.invited,
    required this.photoUrl
  });

  factory InvitableFriend.fromJson(Map<String, dynamic> json) {
    return InvitableFriend(
      userId: json["userId"],
      username: json["username"],
      invited: json["invited"],
      photoUrl: json["photoUrl"] as String?,
    );
  }
}
