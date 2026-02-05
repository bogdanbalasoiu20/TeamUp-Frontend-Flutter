class PlayerBehaviorUi {
  final Map<String, int> stats;
  final int feedbackCount;

  PlayerBehaviorUi({
    required this.stats,
    required this.feedbackCount,
  });

  factory PlayerBehaviorUi.fromJson(Map<String, dynamic> data) {
    return PlayerBehaviorUi(
      stats: {
        "FRP": data['fairPlay'],
        "COM": data['communication'],
        "FUN": data['fun'],
        "CMP": data['competitiveness'],
        "SFH": data['selfishness'],
        "AGR": data['aggressiveness'],
      },
      feedbackCount: data['feedbackCount'],
    );
  }
}
