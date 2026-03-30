enum SquadType {
  PITCH,
  BENCH,
}

class TeamMemberModel {
  final String userId;
  final String username;
  final String role;
  final DateTime joinedAt;
  final SquadType squadType;
  final int slotIndex;
  final String? photoUrl;

  TeamMemberModel({
    required this.userId,
    required this.username,
    required this.role,
    required this.joinedAt,
    required this.squadType,
    required this.slotIndex,
    required this.photoUrl
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      userId: json["userId"] ?? "",
      username: json["username"] ?? "",
      role: json["role"] ?? "",
      joinedAt: json["joinedAt"] != null
          ? DateTime.parse(json["joinedAt"])
          : DateTime.now(),

      squadType: json["squadType"] != null
          ? SquadType.values.firstWhere(
            (e) => e.name == json["squadType"],
        orElse: () => SquadType.BENCH,
      )
          : SquadType.BENCH,

      slotIndex: json["slotIndex"] ?? 0,

      photoUrl: json["photoUrl"] as String?,
    );
  }
}