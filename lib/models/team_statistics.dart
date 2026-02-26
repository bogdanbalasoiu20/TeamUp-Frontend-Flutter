class TeamStatisticsModel {
  final String teamId;
  final String teamName;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int tournamentsPlayed;
  final int tournamentsWon;

  TeamStatisticsModel({
    required this.teamId,
    required this.teamName,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.tournamentsPlayed,
    required this.tournamentsWon,
  });

  factory TeamStatisticsModel.fromJson(Map<String, dynamic> json) {
    return TeamStatisticsModel(
      teamId: json["teamId"],
      teamName: json["teamName"],
      played: json["played"],
      wins: json["wins"],
      draws: json["draws"],
      losses: json["losses"],
      goalsFor: json["goalsFor"],
      goalsAgainst: json["goalsAgainst"],
      tournamentsPlayed: json["tournamentsPlayed"],
      tournamentsWon: json["tournamentsWon"],
    );
  }
}