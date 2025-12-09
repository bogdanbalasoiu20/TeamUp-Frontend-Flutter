import 'package:team_up_fe_new/exceptions/api_service.dart';
import '../models/user_search_result.dart';

const String baseUrl = "https://teamup-backend-omi4.onrender.com";

class FriendApi {
  static Future<List<UserSearchResult>> searchUsers(String query) async {
    print("Searching '$query'");

    try {
      final res = await ApiService.get(
        "$baseUrl/api/friends/requests/search?query=$query",
      );
      print("Result: $res");

      final page = res["data"];
      final List content = page["content"];

      return content.map((u) => UserSearchResult.fromJson(u)).toList();
    } catch (e, st) {
      print("ERROR SEARCHING USERS: $e");
      print(st);
      rethrow;
    }
  }

  static Future<void> sendRequest(String addresseeId, {String? message}) async {
    await ApiService.post("/api/friends/requests", {
      "addresseeId": addresseeId,
      "message": message ?? ""
    });
  }

  static Future<void> respond(String requestId, bool accept) async {
    await ApiService.patch("/api/friends/requests/$requestId/respond", {
      "accept": accept
    });
  }

  static Future<List<dynamic>> getIncoming() async {
    final res = await ApiService.get(
      "$baseUrl/api/friends/requests/incoming",
    );
    return res["data"]["content"];
  }

  static Future<List<dynamic>> getOutgoing() async {
    final res = await ApiService.get(
      "$baseUrl/api/friends/requests/outgoing",
    );
    return res["data"]["content"];
  }

  static Future<Map<String, dynamic>> relationStatus(String username) async {
    final res = await ApiService.get(
      "$baseUrl/api/friends/relation/$username",
    );
    return res["data"];
  }
}
