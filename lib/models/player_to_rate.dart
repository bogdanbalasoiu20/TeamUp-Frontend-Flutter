class PlayerToRateModel {
  final String userId;
  final String username;
  final String position;
  final String? photoUrl;

  PlayerToRateModel({
    required this.userId,
    required this.username,
    required this.position,
    required this.photoUrl
  });

  factory PlayerToRateModel.fromJson(Map<String, dynamic> json) {
    return PlayerToRateModel(
      userId: json['userID'],
      username: json['username'],
      position: json['position'],
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
