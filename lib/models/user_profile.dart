class UserProfile {
  final String id;
  final String username;
  final String? email;
  final DateTime? birthday;
  final String? phoneNumber;
  final String? city;
  final String? description;
  final String? rank;
  final String? photoUrl;
  final String? position;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.birthday,
    required this.phoneNumber,
    required this.city,
    required this.description,
    required this.rank,
    required this.photoUrl,
    required this.position,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"],
      username: json["username"],
      email: json["email"],
      birthday: json["birthday"] != null ? DateTime.parse(json["birthday"]) : null,
      phoneNumber: json["phoneNumber"],
      city: json["city"],
      description: json["description"],
      rank: json["rank"],
      photoUrl: json["photoUrl"],
      position: json["position"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "phoneNumber": phoneNumber,
      "position": position,
      "city": city,
      "description": description,
      "rank": rank,
      "photoUrl": photoUrl,
      "birthday": birthday?.toIso8601String(),
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
