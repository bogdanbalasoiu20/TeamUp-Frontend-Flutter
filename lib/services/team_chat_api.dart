import 'package:team_up_fe_new/exceptions/api_service.dart';
import '../models/message.dart';

class TeamChatApi {

  static Future<List<ChatMessage>> fetchMessages(String teamId, {String? after}) async {
    String url = "${ApiService.baseUrl}/api/teams/$teamId/chat/messages";

    if (after != null) {
      url += "?after=$after";
    }

    final res = await ApiService.get(url);

    final data = res["data"]["content"];
    return (data as List)
        .map((e) => ChatMessage.fromJson(e))
        .toList();
  }

  static Future<ChatMessage> sendMessage(String teamId, String content) async {
    final res = await ApiService.post(
      "/api/teams/$teamId/chat/messages",
      {"content": content},
    );

    return ChatMessage.fromJson(res["data"]);
  }
}