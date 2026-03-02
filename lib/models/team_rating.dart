class TeamRatingModel {
  final int attack;
  final int midfield;
  final int defense;
  final int overall;

  TeamRatingModel({
    required this.attack,
    required this.midfield,
    required this.defense,
    required this.overall,
  });

  factory TeamRatingModel.fromJson(Map<String, dynamic> json) {
    return TeamRatingModel(
      attack: json["attack"],
      midfield: json["midfield"],
      defense: json["defense"],
      overall: json["overall"],
    );
  }
}