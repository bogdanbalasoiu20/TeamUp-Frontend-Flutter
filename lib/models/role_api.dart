class UserRole {
  final String role;

  UserRole({required this.role});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      role: json["role"],
    );
  }
}
