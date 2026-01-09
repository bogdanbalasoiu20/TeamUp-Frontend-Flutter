class MatchInfo {
  final String id;
  final String creatorId;

  final String venueId;
  final String venueName;
  final String venueAddress;
  final double lat;
  final double lng;

  final DateTime startsAt;
  final DateTime? endsAt;
  final int durationMinutes;

  final int maxPlayers;
  final int currentPlayers;

  final DateTime? joinDeadline;

  final String title;
  final String notes;

  final String status;
  final String visibility;

  final double totalPrice;

  MatchInfo({
    required this.id,
    required this.creatorId,
    required this.venueId,
    required this.venueName,
    required this.venueAddress,
    required this.lat,
    required this.lng,
    required this.startsAt,
    required this.endsAt,
    required this.durationMinutes,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.joinDeadline,
    required this.title,
    required this.notes,
    required this.status,
    required this.visibility,
    required this.totalPrice,
  });

  factory MatchInfo.fromJson(Map<String, dynamic> json) {
    final venue = json["venue"] ?? {};
    final creator = json["creator"] ?? {};

    return MatchInfo(
      id: json["id"]?.toString() ?? "",
      creatorId: creator["id"]?.toString() ?? "",

      venueId: venue["id"]?.toString() ?? "",
      venueName: venue["name"]?.toString() ?? "",
      venueAddress: venue["address"]?.toString() ?? "",

      lat: (venue["lat"] ?? 0).toDouble(),
      lng: (venue["lng"] ?? 0).toDouble(),

      startsAt: DateTime.parse(json["startsAt"]),
      endsAt: json["endsAt"] != null ? DateTime.parse(json["endsAt"]) : null,

      durationMinutes: json["durationMinutes"] ?? 0,
      maxPlayers: json["maxPlayers"] ?? 0,
      currentPlayers: json["currentPlayers"] ?? 0,

      joinDeadline: json["joinDeadline"] != null
          ? DateTime.parse(json["joinDeadline"])
          : null,

      title: json["title"]?.toString() ?? "",
      notes: json["notes"]?.toString() ?? "",

      status: json["status"]?.toString() ?? "UNKNOWN",
      visibility: json["visibility"]?.toString() ?? "PUBLIC",

      totalPrice: (json["totalPrice"] ?? 0).toDouble(),
    );
  }
}
