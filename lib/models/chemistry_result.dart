import 'chemistry_reason.dart';

class ChemistryResult {
  final int score;
  final double similarity;
  final List<ChemistryReason> reasons;
  final String yourRole;
  final String otherRole;

  ChemistryResult({
    required this.score,
    required this.similarity,
    required this.reasons,
    required this.yourRole,
    required this.otherRole
  });

  factory ChemistryResult.fromJson(Map<String, dynamic> json) {
    return ChemistryResult(
      score: json['score'],
      similarity: (json['similarity'] as num).toDouble(),
      reasons: (json['reasons'] as List<dynamic>? ?? [])
          .map((r) => ChemistryReason.fromJson(r))
          .toList(),
      yourRole: json['yourRole'],
      otherRole: json['otherRole'],
    );
  }
}
