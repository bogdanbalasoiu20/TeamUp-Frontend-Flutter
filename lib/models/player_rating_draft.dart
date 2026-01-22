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

  Map<String, dynamic> toJson(String ratedUserId) {
    return {
      "ratedUserId": ratedUserId,
      "pace": pace,
      "shooting": shooting,
      "passing": passing,
      "defending": defending,
      "dribbling": dribbling,
      "physical": physical,
      "gkDiving": gkDiving,
      "gkHandling": gkHandling,
      "gkKicking": gkKicking,
      "gkReflexes": gkReflexes,
      "gkSpeed": gkSpeed,
      "gkPositioning": gkPositioning
    };
  }
}
