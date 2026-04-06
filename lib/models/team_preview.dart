class TeamPreview {
  final String name;
  final String? badgeUrl;

  TeamPreview({
    required this.name,
    required this.badgeUrl,
  });

  factory TeamPreview.fromJson(Map<String, dynamic> json) {
    return TeamPreview(
      name: json["name"],
      badgeUrl: json["badgeUrl"],
    );
  }
}