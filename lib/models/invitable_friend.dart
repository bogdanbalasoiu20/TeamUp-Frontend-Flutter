class InvitableFriend {
  final String userId;
  final String username;
  final bool invited;

  InvitableFriend({
    required this.userId,
    required this.username,
    required this.invited,
  });

  factory InvitableFriend.fromJson(Map<String, dynamic> json) {
    return InvitableFriend(
      userId: json["userId"],
      username: json["username"],
      invited: json["invited"],
    );
  }
}
