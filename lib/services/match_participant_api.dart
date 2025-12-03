import 'package:team_up_fe_new/exceptions/api_service.dart';
import '../models/participant.dart';

class MatchParticipantApi{
  static const String baseUrl = "https://teamup-backend-omi4.onrender.com";

  static Future<List<Participant>> fetchParticipants(String matchId) async{
    final data= await ApiService.get("https://teamup-backend-omi4.onrender.com/api/matches/$matchId/participants");

    final list = data["data"]["content"] as List;

    return list.map((e) => Participant.fromJson(e)).toList();
  }

  static Future<void> joinMatch(String matchId) async{
    await ApiService.post("/api/matches/$matchId/participants/join", {});
  }

  static Future<void> leaveMatch(String matchId) async {
    await ApiService.delete("/api/matches/$matchId/participants/leave");
  }

  static Future<void> cancelRequest(String matchId) async {
    await ApiService.delete("/api/matches/$matchId/participants/leave");
  }

  static Future<void> acceptInvite(String matchId) async {
    await ApiService.post(
      "/api/matches/$matchId/participants/accept-invite",
      {},
    );
  }


  static Future<void> leaveWaitlist(String matchId) async {
    await ApiService.post(
      "/api/matches/$matchId/participants/leave-waitlist",
      {},
    );
  }
}