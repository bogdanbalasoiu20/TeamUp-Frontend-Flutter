class UpcomingTournamentModel {
  final String id;
  final String name;
  final DateTime startsAt;
  final String? teamName;
  final String? teamBadgeUrl;
  final String? location;

  UpcomingTournamentModel({
    required this.id,
    required this.name,
    required this.startsAt,
    this.teamName,
    this.teamBadgeUrl,
    this.location,
  });

  factory UpcomingTournamentModel.fromJson(Map<String, dynamic> json) {
    return UpcomingTournamentModel(
      id: json["id"],
      name: json["name"],
      startsAt: DateTime.parse(json["startsAt"]),
      teamName: json["teamName"],
      teamBadgeUrl: json["teamBadgeUrl"],
      location: json["location"],
    );
  }
}