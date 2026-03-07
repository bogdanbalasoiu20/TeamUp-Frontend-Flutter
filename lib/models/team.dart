import 'package:team_up_fe_new/models/team_rating.dart';

class TeamModel {
  final String id;
  final String name;
  final String captainUsername;
  final int teamChemistry;
  final DateTime createdAt;
  final TeamRatingModel rating;

  TeamModel({
    required this.id,
    required this.name,
    required this.captainUsername,
    required this.teamChemistry,
    required this.createdAt,
    required this.rating,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json["id"],
      name: json["name"],
      captainUsername: json["captainUsername"],
      teamChemistry: json["teamChemistry"],
      createdAt: DateTime.parse(json["createdAt"]),
      rating: TeamRatingModel.fromJson(json["rating"]),
    );
  }
}