class PlayerCardApiModel {
  final String userId;
  final String name;
  final String position;
  final int overall;
  final String imageUrl;
  final Map<String, int> stats;

  PlayerCardApiModel({
    required this.userId,
    required this.name,
    required this.position,
    required this.overall,
    required this.imageUrl,
    required this.stats,
  });

  factory PlayerCardApiModel.fromJson(Map<String, dynamic> json) {
    return PlayerCardApiModel(
      userId: json['userId'],
      name: json['name'],
      position: json['position'],
      overall: json['overall'],
      imageUrl: json['imageUrl'],
      stats: Map<String, int>.from(json['stats']),
    );
  }
}
