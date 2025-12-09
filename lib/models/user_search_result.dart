class UserSearchResult {
  final String id;
  final String username;
  final String photoUrl;

  final bool isFriend;
  final bool pendingSent;
  final bool pendingReceived;

  UserSearchResult({
    required this.id,
    required this.username,
    required this.photoUrl,
    required this.isFriend,
    required this.pendingSent,
    required this.pendingReceived,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json["id"],
      username: json["username"],
      photoUrl: json["photoUrl"] ?? "",
      isFriend: json["isFriend"],
      pendingSent: json["pendingSent"],
      pendingReceived: json["pendingReceived"],
    );
  }
}
