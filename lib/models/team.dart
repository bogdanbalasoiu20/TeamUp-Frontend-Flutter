class TeamModel {
  final String id;
  final String name;
  final String captainUsername;
  final int teamChemistry;
  final DateTime createdAt;

  final int overallRating;
  final int attackRating;
  final int midfieldRating;
  final int defenseRating;

  TeamModel({
    required this.id,
    required this.name,
    required this.captainUsername,
    required this.teamChemistry,
    required this.createdAt,
    required this.overallRating,
    required this.attackRating,
    required this.midfieldRating,
    required this.defenseRating,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json["id"],
      name: json["name"],
      captainUsername: json["captainUsername"],
      teamChemistry: json["teamChemistry"],
      createdAt: DateTime.parse(json["createdAt"]),
      overallRating: json["overallRating"],
      attackRating: json["attackRating"],
      midfieldRating: json["midfieldRating"],
      defenseRating: json["defenseRating"],
    );
  }
}