class PlayerCardHistoryPoint {
  final DateTime recordedAt;
  final double overallRating;

  // final String eventType;
  // final String? contextId;

  final double? pace;
  final double? shooting;
  final double? passing;
  final double? dribbling;
  final double? defending;
  final double? physical;

  final double? gkDiving;
  final double? gkHandling;
  final double? gkKicking;
  final double? gkReflexes;
  final double? gkSpeed;
  final double? gkPositioning;

  PlayerCardHistoryPoint({
    required this.recordedAt,
    required this.overallRating,
    // required this.eventType,
    // this.contextId,
    this.pace,
    this.shooting,
    this.passing,
    this.dribbling,
    this.defending,
    this.physical,
    this.gkDiving,
    this.gkHandling,
    this.gkKicking,
    this.gkReflexes,
    this.gkSpeed,
    this.gkPositioning,
  });

  factory PlayerCardHistoryPoint.fromJson(Map<String, dynamic> json) {
    return PlayerCardHistoryPoint(
      recordedAt: DateTime.parse(json['recordedAt']),
      overallRating: (json['overallRating'] as num).toDouble(),
      // eventType: json['eventType'],
      // contextId: json['contextId'],
      pace: (json['pace'] as num?)?.toDouble(),
      shooting: (json['shooting'] as num?)?.toDouble(),
      passing: (json['passing'] as num?)?.toDouble(),
      dribbling: (json['dribbling'] as num?)?.toDouble(),
      defending: (json['defending'] as num?)?.toDouble(),
      physical: (json['physical'] as num?)?.toDouble(),
      gkDiving: (json['gkDiving'] as num?)?.toDouble(),
      gkHandling: (json['gkHandling'] as num?)?.toDouble(),
      gkKicking: (json['gkKicking'] as num?)?.toDouble(),
      gkReflexes: (json['gkReflexes'] as num?)?.toDouble(),
      gkSpeed: (json['gkSpeed'] as num?)?.toDouble(),
      gkPositioning: (json['gkPositioning'] as num?)?.toDouble(),
    );
  }
}
