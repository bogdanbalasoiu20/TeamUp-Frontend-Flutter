class UserHomeStats {
  final int rating;
  final String? position;
  final String? avatarUrl;
  final int ratingChange;

  UserHomeStats({
    required this.rating,
    this.position,
    this.avatarUrl,
    required this.ratingChange,
  });

  factory UserHomeStats.fromJson(Map<String, dynamic> json) {
    return UserHomeStats(
      rating: json["rating"],
      position: json["position"],
      avatarUrl: json["avatarUrl"],
      ratingChange: json["ratingChange"],
    );
  }
}