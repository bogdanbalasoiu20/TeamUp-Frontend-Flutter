class PlayerRatingDraft {
  int? pace;
  int? shooting;
  int? passing;
  int? defending;
  int? dribbling;
  int? physical;

  int? gkDiving;
  int? gkHandling;
  int? gkKicking;
  int? gkReflexes;
  int? gkSpeed;
  int? gkPositioning;

  int? fairPlay;
  int? communication;
  int? fun;
  int? competitiveness;
  int? adaptability;
  int? reliability;

  Map<String, dynamic> toJson(String ratedUserId, String position) {
    final Map<String, dynamic> data = {
      "ratedUserId": ratedUserId,
    };

    if (position == "GOALKEEPER") {
      data.addAll({
        "gkDiving": gkDiving,
        "gkHandling": gkHandling,
        "gkKicking": gkKicking,
        "gkReflexes": gkReflexes,
        "gkSpeed": gkSpeed,
        "gkPositioning": gkPositioning,
      });
    } else {
      data.addAll({
        "pace": pace,
        "shooting": shooting,
        "passing": passing,
        "defending": defending,
        "dribbling": dribbling,
        "physical": physical,
      });
    }

    if (fairPlay != null ||
        communication != null ||
        fun != null ||
        competitiveness != null ||
        adaptability != null ||
        reliability != null) {
      data.addAll({
        "fairPlay": fairPlay,
        "communication": communication,
        "fun": fun,
        "competitiveness": competitiveness,
        "adaptability": adaptability,
        "reliability": reliability,
      });
    }

    return data;
  }


  PlayerRatingDraft copy() {
    return PlayerRatingDraft()
      ..pace = pace
      ..shooting = shooting
      ..passing = passing
      ..defending = defending
      ..dribbling = dribbling
      ..physical = physical
      ..gkDiving = gkDiving
      ..gkHandling = gkHandling
      ..gkKicking = gkKicking
      ..gkReflexes = gkReflexes
      ..gkSpeed = gkSpeed
      ..gkPositioning = gkPositioning
      ..fairPlay = fairPlay
      ..communication = communication
      ..fun = fun
      ..competitiveness = competitiveness
      ..adaptability = adaptability
      ..reliability = reliability;
  }
}
