import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserApi {
  static const baseUrl = "https://teamup-backend-kx26.onrender.com/api/users";

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


  static Future<String> fetchUserRole(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    final url = Uri.parse("$baseUrl/$userId/role");

    final resp = await http.get(url, headers: {
      "Content-Type": "application/json",
      if (prefs.getString("access_token") != null)
        "Authorization": "Bearer ${prefs.getString("access_token")}",
    });

    final json = jsonDecode(resp.body);
    final data = json["data"];

    return data["role"];
  }



  static Future<String?> uploadAvatar({
    required String filePath,
    required String token,
  }) async {
    var uri = Uri.parse("$baseUrl/me/upload-avatar");

    var request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    var response = await request.send();

    print("STATUS: ${response.statusCode}");

    final body = await response.stream.bytesToString();
    print("BODY: $body");

    if (response.statusCode == 200) {
      final json = jsonDecode(body);
      return json['data'];
    } else {
      final json = jsonDecode(body);
      throw Exception(json['error']?['message'] ?? "Upload failed");
    }

    return null;
  }

}

