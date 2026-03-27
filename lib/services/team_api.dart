import 'dart:convert';

import 'package:team_up_fe_new/models/team.dart';
import 'package:team_up_fe_new/models/team_full_profile.dart';
import 'package:team_up_fe_new/models/team_member.dart';
import 'package:team_up_fe_new/models/page_model.dart';
import '../exceptions/api_service.dart';
import 'package:http/http.dart' as http;

class TeamApi {

  /// CREATE TEAM
  static Future<TeamModel> createTeam(String name) async {
    print("API CALL: Creating team with name: $name");

    final response = await ApiService.post(
      "/api/teams",
      {
        "name": name,
      },
    );

    print("API RESPONSE: $response");

    return TeamModel.fromJson(response["data"]);
  }

  /// ADD PLAYER
  static Future<void> addPlayer(String teamId, String userId) async {
    await ApiService.post(
      "/api/teams/$teamId/members/$userId",
      {},
    );
  }

  /// REMOVE PLAYER
  static Future<void> removePlayer(String teamId, String userId) async {
    await ApiService.delete(
      "/api/teams/$teamId/members/$userId",
    );
  }

  /// GET TEAM DETAILS
  static Future<TeamModel> getTeam(String teamId) async {
    final response = await ApiService.get(
      "${ApiService.baseUrl}/api/teams/$teamId",
    );

    return TeamModel.fromJson(response["data"]);
  }

  /// GET TEAM MEMBERS
  static Future<List<TeamMemberModel>> getMembers(String teamId) async {
    final response = await ApiService.get(
      "${ApiService.baseUrl}/api/teams/$teamId/members",
    );

    return (response["data"] as List)
        .map((e) => TeamMemberModel.fromJson(e))
        .toList();
  }

  /// GET MY TEAMS
  static Future<List<TeamModel>> getMyTeams() async {
    final response = await ApiService.get(
      "${ApiService.baseUrl}/api/teams/my",
    );

    return (response["data"] as List)
        .map((e) => TeamModel.fromJson(e))
        .toList();
  }

  /// EXPLORE TEAMS (paginated + search)
  static Future<PageModel<TeamModel>> exploreTeams({
    int page = 0,
    int size = 10,
    String? search,
  }) async {

    final query = StringBuffer(
        "${ApiService.baseUrl}/api/teams/explore?page=$page&size=$size"
    );

    if (search != null && search.isNotEmpty) {
      query.write("&search=$search");
    }

    final response = await ApiService.get(query.toString());

    return PageModel.fromJson(
      response["data"],
          (json) => TeamModel.fromJson(json),
    );
  }


  static Future<TeamModel> updatePosition({
    required String teamId,
    required String userId,
    required String squadType,
    required int slotIndex,
  }) async {

    final response = await ApiService.put(
      "/api/teams/$teamId/members/$userId/position",
      {
        "squadType": squadType,
        "slotIndex": slotIndex,
      },
    );

    return TeamModel.fromJson(response["data"]);
  }

  static Future<TeamFullProfileModel> getTeamProfile(String teamId) async {
    final response = await ApiService.get("${ApiService.baseUrl}/api/teams/$teamId/profile");
    return TeamFullProfileModel.fromJson(response["data"]);
  }

  static Future<String?> uploadTeamBadge({
    required String teamId,
    required String filePath,
    required String token,
  }) async {
    var uri = Uri.parse("${ApiService.baseUrl}/api/teams/$teamId/upload-badge");

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
  }
}