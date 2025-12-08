import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class UserApi {
  static const baseUrl = "https://teamup-backend-omi4.onrender.com/api/users";

  static Future<UserProfile> fetchProfile(String username) async {
    final uri = Uri.parse("$baseUrl/$username");

    final response = await http.get(uri);
    final json = jsonDecode(response.body);

    if (json["success"] == true) {
      return UserProfile.fromJson(json["data"]);
    }

    throw Exception("User not found");
  }

  static Future<UserProfile> fetchMe() async {
    final uri = Uri.parse("$baseUrl/me");

    final response = await http.get(uri);
    final json = jsonDecode(response.body);

    if (json["success"] == true) {
      return UserProfile.fromJson(json["data"]);
    }

    throw Exception("Unable to load profile");
  }
}
