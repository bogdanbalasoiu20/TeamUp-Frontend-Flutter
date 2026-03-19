class TournamentMatchModel {
  final String id;
  final String homeTeamName;
  final String awayTeamName;
  final int? scoreHome;
  final int? scoreAway;
  final String status;
  final int matchDay;
  final double? oddsHome;
  final double? oddsDraw;
  final double? oddsAway;

  TournamentMatchModel({
    required this.id,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.scoreHome,
    required this.scoreAway,
    required this.status,
    required this.matchDay,
    required this.oddsHome,
    required this.oddsDraw,
    required this.oddsAway
  });

  factory TournamentMatchModel.fromJson(Map<String, dynamic> json) {
    return TournamentMatchModel(
      id: json["id"],
      homeTeamName: json["homeTeamName"],
      awayTeamName: json["awayTeamName"],
      scoreHome: json["scoreHome"],
      scoreAway: json["scoreAway"],
      status: json["status"],
      matchDay: json["matchDay"],
      oddsHome: json["oddsHome"]?.toDouble(),
      oddsDraw: json["oddsDraw"]?.toDouble(),
      oddsAway: json["oddsAway"]?.toDouble(),
    );
  }
}
