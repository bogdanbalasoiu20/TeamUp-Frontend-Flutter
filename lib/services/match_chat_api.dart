import 'package:team_up_fe_new/exceptions/api_service.dart';
import '../models/message.dart';

class MatchChatApi {
  static Future<List<ChatMessage>> fetchMessages(String matchId, {String? after}) async {
    String url = "${ApiService.baseUrl}/api/matches/$matchId/chat/messages";

    if (after != null) {
      url += "?after=$after";
    }

    print("### FINAL URL FETCH: $url");

    final res = await ApiService.get(url);

    final data = res["data"]["content"];
    return (data as List).map((e) => ChatMessage.fromJson(e)).toList();
  }

  static Future<ChatMessage> sendMessage(String matchId, String content) async {
    print("### REST SEND TO: /api/matches/$matchId/chat/messages");

    final res = await ApiService.post(
      "/api/matches/$matchId/chat/messages",
      {"content": content},
    );

    print("### RAW SEND RESPONSE:");
    print(res);

    return ChatMessage.fromJson(res["data"]);
  }
}


