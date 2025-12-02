class MatchPin {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final String startsAt;
  final int maxPlayers;
  final int joinedPlayers;
  final int durationMinutes;
  final double totalPrice;

  MatchPin({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.startsAt,
    required this.maxPlayers,
    required this.joinedPlayers,
    required this.durationMinutes,
    required this.totalPrice
  });

  factory MatchPin.fromJson(Map<String, dynamic> json) {
    print("### RAW PIN JSON = $json");

    return MatchPin(
      id: (json["matchId"] ?? json["id"] ?? "").toString(),
      title: json["title"] ?? "Match",
      latitude: (json["lat"] ?? json["latitude"] ?? 0).toDouble(),
      longitude: (json["lng"] ?? json["longitude"] ?? 0).toDouble(),
      startsAt: json["startsAt"] ?? DateTime.now().toIso8601String(),
      maxPlayers: json["maxPlayers"] ?? json["capacity"] ?? 0,
      joinedPlayers: json["currentPlayers"] ?? json["players"] ?? 0,
      durationMinutes: json["durationMinutes"] ?? json["duration"] ?? 0,
      totalPrice: (json["totalPrice"] ?? json["price"] ?? 0).toDouble(),
    );
  }
}



class MatchItem {
  final String id;
  final String title;
  final String startsAt;
  final int maxPlayers;
  final int currentPlayers;
  final String venueName;

  MatchItem({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.venueName,
  });

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      id: json["id"],
      title: json["title"] ?? "Match",
      startsAt: json["startsAt"],
      maxPlayers: json["maxPlayers"],
      currentPlayers: json["currentPlayers"],
      venueName: json["venueName"] ?? "",
    );
  }
}