class UpcomingMatchModel {
  final String id;
  final String title;
  final DateTime startsAt;
  final String? location;
  final int currentPlayers;
  final int maxPlayers;

  UpcomingMatchModel({
    required this.id,
    required this.title,
    required this.startsAt,
    this.location,
    required this.currentPlayers,
    required this.maxPlayers
  });

  factory UpcomingMatchModel.fromJson(Map<String, dynamic> json) {
    return UpcomingMatchModel(
      id: json["id"],
      title: json["title"],
      startsAt: DateTime.parse(json["startsAt"]),
      location: json["location"],
      currentPlayers: json["currentPlayers"] ?? 0,
      maxPlayers: json["maxPlayers"]
    );
  }
}