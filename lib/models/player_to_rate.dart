class PlayerToRateModel {
  final String userId;
  final String username;
  final String position;

  PlayerToRateModel({
    required this.userId,
    required this.username,
    required this.position,
  });

  factory PlayerToRateModel.fromJson(Map<String, dynamic> json) {
    return PlayerToRateModel(
      userId: json['userID'],
      username: json['username'],
      position: json['position'],
    );
  }
}
