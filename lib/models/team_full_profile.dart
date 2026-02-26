import 'package:team_up_fe_new/models/team.dart';
import 'package:team_up_fe_new/models/team_statistics.dart';
import 'package:team_up_fe_new/models/team_tournament_history.dart';

class TeamFullProfileModel {
  final TeamModel team;
  final TeamStatisticsModel statistics;
  final List<TeamTournamentHistoryModel> tournamentHistory;

  TeamFullProfileModel({
    required this.team,
    required this.statistics,
    required this.tournamentHistory,
  });

  factory TeamFullProfileModel.fromJson(Map<String, dynamic> json) {
    return TeamFullProfileModel(
      team: TeamModel.fromJson(json["team"]),
      statistics: TeamStatisticsModel.fromJson(json["statistics"]),
      tournamentHistory: (json["tournamentHistory"] as List)
          .map((e) => TeamTournamentHistoryModel.fromJson(e))
          .toList(),
    );
  }
}