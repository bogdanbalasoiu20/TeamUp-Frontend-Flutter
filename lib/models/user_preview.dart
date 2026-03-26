class UserPreview {
  final String username;
  final String? imageUrl;

  UserPreview({
    required this.username,
    required this.imageUrl,
  });

  factory UserPreview.fromJson(Map<String, dynamic> json) {
    return UserPreview(
      username: json["username"],
      imageUrl: json["imageUrl"],
    );
  }
}