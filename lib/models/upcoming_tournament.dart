class UpcomingTournamentModel {
  final String id;
  final String name;
  final DateTime startsAt;
  final String? teamName;

  UpcomingTournamentModel({
    required this.id,
    required this.name,
    required this.startsAt,
    this.teamName,
  });

  factory UpcomingTournamentModel.fromJson(Map<String, dynamic> json) {
    return UpcomingTournamentModel(
      id: json["id"],
      name: json["name"],
      startsAt: DateTime.parse(json["startsAt"]),
      teamName: json["teamName"],
    );
  }
}