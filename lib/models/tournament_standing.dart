class TournamentStandingModel {
  final String teamName;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final int? finalPosition;
  final String? badgeUrl;

  TournamentStandingModel({
    required this.teamName,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
    required this.finalPosition,
    required this.badgeUrl
  });

  factory TournamentStandingModel.fromJson(Map<String, dynamic> json) {
    return TournamentStandingModel(
      teamName: json["teamName"],
      played: json["played"],
      wins: json["wins"],
      draws: json["draws"],
      losses: json["losses"],
      goalsFor: json["goalsFor"],
      goalsAgainst: json["goalsAgainst"],
      points: json["points"],
      finalPosition: json["finalPosition"],
      badgeUrl: json["badgeUrl"]
    );
  }
}
