class PlayerBehaviorStats {
  final int fairPlay;
  final int communication;
  final int fun;
  final int competitiveness;
  final int selfishness;
  final int aggressiveness;
  final int feedbackCount;

  PlayerBehaviorStats({
    required this.fairPlay,
    required this.communication,
    required this.fun,
    required this.competitiveness,
    required this.selfishness,
    required this.aggressiveness,
    required this.feedbackCount,
  });

  factory PlayerBehaviorStats.fromJson(Map<String, dynamic> json) {
    return PlayerBehaviorStats(
      fairPlay: json['fairPlay'],
      communication: json['communication'],
      fun: json['fun'],
      competitiveness: json['competitiveness'],
      selfishness: json['selfishness'],
      aggressiveness: json['aggressiveness'],
      feedbackCount: json['feedbackCount'],
    );
  }
}
