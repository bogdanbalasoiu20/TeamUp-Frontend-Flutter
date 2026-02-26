class TeamTournamentHistoryModel {
  final String tournamentId;
  final String tournamentName;
  final int finalPosition;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;

  TeamTournamentHistoryModel({
    required this.tournamentId,
    required this.tournamentName,
    required this.finalPosition,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  factory TeamTournamentHistoryModel.fromJson(Map<String, dynamic> json) {
    return TeamTournamentHistoryModel(
      tournamentId: json["tournamentId"],
      tournamentName: json["tournamentName"],
      finalPosition: json["finalPosition"] ?? 0,
      played: json["played"],
      wins: json["wins"],
      draws: json["draws"],
      losses: json["losses"],
      goalsFor: json["goalsFor"],
      goalsAgainst: json["goalsAgainst"],
    );
  }
}