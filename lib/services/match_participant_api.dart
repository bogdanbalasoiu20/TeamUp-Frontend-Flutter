import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/models/match_participants_response.dart';
import '../models/participant.dart';

class MatchParticipantApi{
  static const String baseUrl = "https://teamup-backend-omi4.onrender.com";

  static Future<MatchParticipantsResponse> fetchParticipants(String matchId) async {
    final data = await ApiService.get("$baseUrl/api/matches/$matchId/participants");

    return MatchParticipantsResponse.fromJson(data["data"]);
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



  static Future<void> approveRequest(String matchId, String userId) async {
    await ApiService.post(
      "/api/matches/$matchId/participants/$userId/approve",
      {},
    );
  }

  static Future<void> rejectRequest(String matchId, String userId) async {
    await ApiService.post(
      "/api/matches/$matchId/participants/$userId/reject",
      {},
    );
  }

  static Future<List<Participant>> fetchWaitlist(String matchId) async {
    final response = await ApiService.get(
      "https://teamup-backend-omi4.onrender.com/api/matches/$matchId/participants",
    );

    final data = response["data"];
    final List<dynamic> list = data["participants"];

    return list
        .where((p) => p["status"] == "WAITLIST")
        .map((p) => Participant.fromJson(p))
        .toList();
  }


  static Future<void> promoteFromWaitlist(String matchId, String userId) async {
    await ApiService.post(
      "/api/matches/$matchId/participants/$userId/promote",
      {},
    );
  }

  static Future<void> moveAllRequestsToWaitlist(String matchId) async {
    await ApiService.post(
      "/api/matches/$matchId/participants/move-requests-to-waitlist",
      {},
    );
  }



}