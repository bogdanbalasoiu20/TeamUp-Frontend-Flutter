class Participant{
  final String userID;
  final String username;
  final String status;
  final bool bringsBall;
  final DateTime createdAt;
  final bool isCreator;

  Participant({
    required this.userID,
    required this.username,
    required this.status,
    required this.bringsBall,
    required this.createdAt,
    required this.isCreator
});
  factory Participant.fromJson(Map<String,dynamic> json){
    return Participant(
      userID:json["userId"],
      username:json["username"],
      status:json["status"],
      bringsBall:json["bringsBall"] ?? false,
      createdAt: DateTime.parse(json["joinedAt"]),
      isCreator: json["isCreator"] ?? false,
    );
  }
}