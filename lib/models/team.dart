class TeamModel {
  final String id;
  final String name;
  final String captainUsername;
  final double teamRating;
  final double teamChemistry;
  final int wins;
  final int draws;
  final int losses;
  final DateTime createdAt;

  TeamModel({
    required this.id,
    required this.name,
    required this.captainUsername,
    required this.teamRating,
    required this.teamChemistry,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.createdAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json["id"],
      name: json["name"],
      captainUsername: json["captainUsername"],
      teamRating: (json["teamRating"] as num).toDouble(),
      teamChemistry: (json["teamChemistry"] as num).toDouble(),
      wins: json["wins"],
      draws: json["draws"],
      losses: json["losses"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}