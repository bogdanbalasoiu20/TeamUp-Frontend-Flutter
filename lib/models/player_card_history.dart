class PlayerCardHistoryPoint {
  final DateTime recordedAt;
  final double overallRating;

  final double? pace;
  final double? shooting;
  final double? passing;
  final double? dribbling;
  final double? defending;
  final double? physical;

  PlayerCardHistoryPoint({
    required this.recordedAt,
    required this.overallRating,
    this.pace,
    this.shooting,
    this.passing,
    this.dribbling,
    this.defending,
    this.physical,
  });

  factory PlayerCardHistoryPoint.fromJson(Map<String, dynamic> json) {
    return PlayerCardHistoryPoint(
      recordedAt: DateTime.parse(json['recordedAt']),
      overallRating: (json['overallRating'] as num).toDouble(),
      pace: (json['pace'] as num?)?.toDouble(),
      shooting: (json['shooting'] as num?)?.toDouble(),
      passing: (json['passing'] as num?)?.toDouble(),
      dribbling: (json['dribbling'] as num?)?.toDouble(),
      defending: (json['defending'] as num?)?.toDouble(),
      physical: (json['physical'] as num?)?.toDouble(),
    );
  }
}
