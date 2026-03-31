import 'package:team_up_fe_new/models/upcoming_match.dart';
import 'package:team_up_fe_new/models/upcoming_tournament.dart';

class HomeUpcomingModel {
  final List<UpcomingMatchModel> matches;
  final List<UpcomingTournamentModel> tournaments;

  HomeUpcomingModel({
    required this.matches,
    required this.tournaments,
  });

  factory HomeUpcomingModel.fromJson(Map<String, dynamic> json) {
    return HomeUpcomingModel(
      matches: (json["matches"] as List? ?? [])
          .map((e) => UpcomingMatchModel.fromJson(e))
          .toList(),
      tournaments: (json["tournaments"] as List? ?? [])
          .map((e) => UpcomingTournamentModel.fromJson(e))
          .toList(),
    );
  }
}