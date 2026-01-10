class FinishPendingMatch {
  final String id;

  FinishPendingMatch({required this.id});

  factory FinishPendingMatch.fromJson(Map<String, dynamic> json) {
    return FinishPendingMatch(id: json["id"]);
  }
}
