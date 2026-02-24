class TournamentModel {
  final String id;
  final String name;

  final String venueId;
  final String venueName;
  final double venueLatitude;
  final double venueLongitude;

  final String status;
  final DateTime startsAt;
  final DateTime endsAt;

  final String creatorUsername;

  TournamentModel({
    required this.id,
    required this.name,
    required this.venueId,
    required this.venueName,
    required this.venueLatitude,
    required this.venueLongitude,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.creatorUsername
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json["id"],
      name: json["name"],
      venueId: json["venueId"],
      venueName: json["venueName"],
      venueLatitude: (json["venueLatitude"] as num).toDouble(),
      venueLongitude: (json["venueLongitude"] as num).toDouble(),
      status: json["status"],
      startsAt: DateTime.parse(json["startsAt"]),
      endsAt: DateTime.parse(json["endsAt"]),
      creatorUsername: json["creatorUsername"],
    );
  }
}
