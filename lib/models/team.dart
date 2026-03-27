import 'package:team_up_fe_new/models/team_chemistry_link.dart';

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

  final List<TeamChemistryLinkModel> links;

  final String? badgeUrl;

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
    required this.links,
    required this.badgeUrl
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
      links: (json["chemistryLinks"] as List?)
          ?.map((e) => TeamChemistryLinkModel.fromJson(e))
          .toList() ??
          [],
      badgeUrl: json["badgeUrl"]
    );
  }
}