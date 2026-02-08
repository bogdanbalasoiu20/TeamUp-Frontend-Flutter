import 'chemistry_reason.dart';

class ChemistryResult {
  final int score;
  final double similarity;
  final List<ChemistryReason> reasons;

  ChemistryResult({
    required this.score,
    required this.similarity,
    required this.reasons,
  });

  factory ChemistryResult.fromJson(Map<String, dynamic> json) {
    return ChemistryResult(
      score: json['score'],
      similarity: (json['similarity'] as num).toDouble(),
      reasons: (json['reasons'] as List<dynamic>? ?? [])
          .map((r) => ChemistryReason.fromJson(r))
          .toList(),
    );
  }
}
