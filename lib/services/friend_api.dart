import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/models/friend_request.dart';
import 'package:team_up_fe_new/models/friendship.dart';
import '../models/user_search_result.dart';

const String baseUrl = "https://teamup-backend-omi4.onrender.com";

class FriendApi {
  static Future<List<UserSearchResult>> searchUsers(String query) async {
    final res = await ApiService.get("$baseUrl/api/friends/requests/search?query=$query");
    final page = res["data"];
    final List items = page["content"];

    return items.map((e) => UserSearchResult.fromJson(e)).toList();
  }

  static Future<void> sendRequest(String addresseeId) async {
    await ApiService.post("/api/friends/requests", {
      "addresseeId": addresseeId,
      "message": ""
    });
  }

  static Future<void> respond(String requestId, bool accept) async {
    await ApiService.post("/api/friends/requests/$requestId/respond", {
      "accept": accept
    });
  }

  static Future<List<FriendRequest>> getIncoming() async {
    final res = await ApiService.get("$baseUrl/api/friends/requests/incoming");
    final List raw = res["data"]["content"];

    print("INCOMING RAW: $raw");

    return raw.map<FriendRequest>((item) {
      if (item is Map<String, dynamic>) {
        return FriendRequest.fromJson(item);
      }

      final mapped = Map<String, dynamic>.from(item);
      return FriendRequest.fromJson(mapped);
    }).toList();
  }



  static Future<List<FriendRequest>> getOutgoing() async {
    final res = await ApiService.get("$baseUrl/api/friends/requests/outgoing");
    final list = res["data"]["content"] as List;

    return list.map((e) => FriendRequest.fromJson(e)).toList();
  }


  static Future<Map<String, dynamic>> relationStatus(String username) async {
    final res = await ApiService.get(
      "$baseUrl/api/friends/relation/$username",
    );
    return res["data"];
  }

  static Future<List<Friendship>> getFriends() async {
    final res = await ApiService.get(
      "$baseUrl/api/friends",
    );

    final List content = res["data"]["content"];
    return content.map((e) => Friendship.fromJson(e)).toList();
  }

  static Future<void> unfriend(String friendId) async {
    final res = await ApiService.delete("/api/friends/$friendId");
    return;
  }

  static Future<void> cancelRequest(String requestId) async {
    return ApiService.delete("/api/friends/request/$requestId");
  }



}
