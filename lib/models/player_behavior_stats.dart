class PlayerBehaviorStats {
  final int fairPlay;
  final int communication;
  final int fun;
  final int competitiveness;
  final int adaptability;
  final int reliability;
  final int feedbackCount;

  PlayerBehaviorStats({
    required this.fairPlay,
    required this.communication,
    required this.fun,
    required this.competitiveness,
    required this.adaptability,
    required this.reliability,
    required this.feedbackCount,
  });

  factory PlayerBehaviorStats.fromJson(Map<String, dynamic> json) {
    return PlayerBehaviorStats(
      fairPlay: json['fairPlay'],
      communication: json['communication'],
      fun: json['fun'],
      competitiveness: json['competitiveness'],
      adaptability: json['adaptability'],
      reliability: json['reliability'],
      feedbackCount: json['feedbackCount'],
    );
  }
}
