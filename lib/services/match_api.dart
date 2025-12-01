import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/exceptions/api_service.dart';

class MatchApi {
  static const baseUrl = "https://teamup-backend-omi4.onrender.com/api/matches";

 
  static Future<bool> createMatch({
    required String venueId,
    required DateTime startsAt,
    int? durationMinutes,
    int? maxPlayers,
    DateTime? joinDeadline,
    String? title,
    String? notes,
    double? totalPrice,
    String? visibility,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final body = jsonEncode({
      "venueId": venueId,
      "startsAt": startsAt.toUtc().toIso8601String(),
      "durationMinutes": durationMinutes,
      "maxPlayers": maxPlayers,
      "joinDeadline": joinDeadline?.toUtc().toIso8601String(),
      "title": title,
      "notes": notes,
      "totalPrice": totalPrice,
      "visibility": visibility,
    });

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    print("### CREATE MATCH STATUS = ${response.statusCode}");
    print("### CREATE MATCH BODY = ${response.body}");

    return response.statusCode == 201;
  }


  static Future<List<MatchPin>> fetchPins({
    required double minLat,
    required double minLng,
    required double maxLat,
    required double maxLng,
  }) async {
    final uri = Uri.parse(
        "https://teamup-backend-omi4.onrender.com/api/matches/nearby-bbox")
        .replace(queryParameters: {
      "minLat": minLat.toString(),
      "minLng": minLng.toString(),
      "maxLat": maxLat.toString(),
      "maxLng": maxLng.toString(),
    });

    print("### FETCH PINS URI = $uri");

    final json = await ApiService.get(uri.toString());

    if (json["data"] == null) return [];

    final List list = json["data"];
    return list.map((e) => MatchPin.fromJson(e)).toList();
  }


  static Future<List<MatchItem>> getAllMatches() async {
    final json = await ApiService.get("/api/matches");

    if (json["data"] == null) return [];

    final List content = json["data"]["content"];

    return content.map((e) => MatchItem.fromJson(e)).toList();
  }
}




class MatchPin {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final String startsAt;
  final int maxPlayers;
  final int joinedPlayers;

  MatchPin({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.startsAt,
    required this.maxPlayers,
    required this.joinedPlayers,
  });

  factory MatchPin.fromJson(Map<String, dynamic> json) {
    return MatchPin(
      id: json["matchId"],
      title: json["title"] ?? "Match",
      latitude: (json["lat"] as num).toDouble(),
      longitude: (json["lng"] as num).toDouble(),
      startsAt: json["startsAt"],
      maxPlayers: json["maxPlayers"],
      joinedPlayers: json["currentPlayers"],
    );
  }
}



class MatchItem {
  final String id;
  final String title;
  final String startsAt;
  final int maxPlayers;
  final int currentPlayers;
  final String venueName;

  MatchItem({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.venueName,
  });

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      id: json["id"],
      title: json["title"] ?? "Match",
      startsAt: json["startsAt"],
      maxPlayers: json["maxPlayers"],
      currentPlayers: json["currentPlayers"],
      venueName: json["venueName"] ?? "",
    );
  }
}
