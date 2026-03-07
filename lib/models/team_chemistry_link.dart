class TeamChemistryLinkModel {
  final String playerA;
  final String playerB;
  final int chemistry;

  TeamChemistryLinkModel({
    required this.playerA,
    required this.playerB,
    required this.chemistry,
  });

  factory TeamChemistryLinkModel.fromJson(Map<String, dynamic> json) {
    return TeamChemistryLinkModel(
      playerA: json["playerA"],
      playerB: json["playerB"],
      chemistry: json["chemistry"],
    );
  }
}