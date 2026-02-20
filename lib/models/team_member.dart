class TeamMemberModel {
  final String userId;
  final String username;
  final String role;
  final DateTime joinedAt;

  TeamMemberModel({
    required this.userId,
    required this.username,
    required this.role,
    required this.joinedAt,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      userId: json["userId"],
      username: json["username"],
      role: json["role"],
      joinedAt: DateTime.parse(json["joinedAt"]),
    );
  }
}