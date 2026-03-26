class Friendship {
  final String userId;
  final String username;
  final String? city;
  final DateTime since;
  final String? photoUrl;

  Friendship({
    required this.userId,
    required this.username,
    required this.city,
    required this.since,
    required this.photoUrl
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      userId: json["userId"],
      username: json["username"],
      city: json["city"],
      since: DateTime.parse(json["since"]),
      photoUrl: json["photoUrl"] as String?,
    );
  }
}
