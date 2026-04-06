import 'package:team_up_fe_new/models/team_preview.dart';

class TournamentModel {
  final String id;
  final String name;

  final String venueId;
  final String venueName;
  final double venueLatitude;
  final double venueLongitude;

  final int maxTeams;
  final String? description;
  final int playersPerTeam;

  final String status;
  final DateTime startsAt;
  final DateTime endsAt;

  final String creatorUsername;

  final List<TeamPreview> teamPreview;
  final int totalTeams;

  TournamentModel({
    required this.id,
    required this.name,
    required this.venueId,
    required this.venueName,
    required this.venueLatitude,
    required this.venueLongitude,
    required this.maxTeams,
    required this.playersPerTeam,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.creatorUsername,
    required this.teamPreview,
    required this.totalTeams,
    this.description,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json["id"],
      name: json["name"],
      venueId: json["venueId"],
      venueName: json["venueName"],
      venueLatitude: (json["venueLatitude"] as num).toDouble(),
      venueLongitude: (json["venueLongitude"] as num).toDouble(),
      maxTeams: json["maxTeams"],
      playersPerTeam: json["playersPerTeam"],
      description: json["description"],
      status: json["status"],
      startsAt: DateTime.parse(json["startsAt"]),
      endsAt: DateTime.parse(json["endsAt"]),
      creatorUsername: json["creatorUsername"],

      teamPreview: (json["teamPreview"] as List<dynamic>?)
          ?.map((e) => TeamPreview.fromJson(e))
          .toList() ??
          [],

      totalTeams: json["totalTeams"] ?? 0,
    );
  }
}