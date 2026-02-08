class ChemistryReason {
  final String message;
  final String type;

  ChemistryReason({
    required this.message,
    required this.type,
  });

  factory ChemistryReason.fromJson(Map<String, dynamic> json) {
    return ChemistryReason(
      message: json['message'],
      type: json['type'],
    );
  }

  bool get isPositive => type == 'POSITIVE';
  bool get isNegative => type == 'NEGATIVE';
  bool get isNeutral => type == 'NEUTRAL';
}
