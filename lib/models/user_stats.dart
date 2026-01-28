class UserStats {
  final int matchesPlayed;
  final int matchesCreated;
  final int votesGiven;
  final int votesReceived;
  final double currentRating;
  final double maxRating;

  UserStats({
    required this.matchesPlayed,
    required this.matchesCreated,
    required this.votesGiven,
    required this.votesReceived,
    required this.currentRating,
    required this.maxRating,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      matchesPlayed: json['matchesPlayed'],
      matchesCreated: json['matchesCreated'],
      votesGiven: json['votesGiven'],
      votesReceived: json['votesReceived'],
      currentRating: (json['currentRating'] as num).toDouble(),
      maxRating: (json['maxRating'] as num).toDouble(),
    );
  }
}
