class ChemistryResult {
  final int score;
  final double similarity;
  final List<String> reasons;

  ChemistryResult({
    required this.score,
    required this.similarity,
    required this.reasons,
  });

  factory ChemistryResult.fromJson(Map<String, dynamic> json) {
    return ChemistryResult(
      score: json['score'],
      similarity: (json['similarity'] as num).toDouble(),
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }
}
