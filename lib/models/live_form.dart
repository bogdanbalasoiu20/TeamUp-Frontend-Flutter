class LiveForm {
  final double recentOverall;
  final double delta;
  final int matchesCount;

  LiveForm({
    required this.recentOverall,
    required this.delta,
    required this.matchesCount,
  });

  factory LiveForm.fromJson(Map<String, dynamic> json) {
    return LiveForm(
      recentOverall: (json['recentOverall'] as num).toDouble(),
      delta: (json['delta'] as num).toDouble(),
      matchesCount: json['matchesCount'] as int,
    );
  }
}
