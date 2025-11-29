import 'dart:convert';
import 'package:http/http.dart' as http;

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
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    return response.statusCode == 201;
  }
}
