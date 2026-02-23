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

  TeamMemberModel({
    required this.userId,
    required this.username,
    required this.role,
    required this.joinedAt,
    required this.squadType,
    required this.slotIndex,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      userId: json["userId"],
      username: json["username"],
      role: json["role"],
      joinedAt: DateTime.parse(json["joinedAt"]),
      squadType: SquadType.values.firstWhere(
            (e) => e.name == json["squadType"],
      ),
      slotIndex: json["slotIndex"],
    );
  }
}