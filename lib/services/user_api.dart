import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserApi {
  static const baseUrl = "https://teamup-backend-omi4.onrender.com/api/users";

  static Future<UserProfile> fetchProfile(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final logged = prefs.getString("username");

    late Uri url;

    if (logged != null && logged == username) {
      url = Uri.parse("$baseUrl/me");
    } else {
      url = Uri.parse("$baseUrl/$username");
    }

    final resp = await http.get(url, headers: {
      "Content-Type": "application/json",
      if (prefs.getString("access_token") != null)
        "Authorization": "Bearer ${prefs.getString("access_token")}",
    });

    final json = jsonDecode(resp.body);
    final data = json["data"];

    return UserProfile.fromJson(data);
  }
}

