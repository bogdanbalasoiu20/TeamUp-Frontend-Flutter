import 'package:team_up_fe_new/exceptions/api_service.dart';


class TournamentApi {

  /// CREATE TOURNAMENT
  static Future<Map<String, dynamic>> createTournament({
    required String name,
    required String venueId,
    required int maxTeams,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {

    final response = await ApiService.post(
      "/api/tournaments",
      {
        "name": name,
        "venueId": venueId,
        "maxTeams": maxTeams,
        "startsAt": startsAt.toIso8601String(),
        "endsAt": endsAt.toIso8601String(),
      },
    );

    return response["data"];
  }

  /// JOIN TOURNAMENT
  static Future<void> joinTournament(
      String tournamentId, String teamId) async {

    await ApiService.post(
      "/api/tournaments/$tournamentId/join/$teamId",
      {},
    );
  }

  /// START TOURNAMENT
  static Future<void> startTournament(String tournamentId) async {
    await ApiService.post(
      "/api/tournaments/$tournamentId/start",
      {},
    );
  }

  /// GET TOURNAMENT DETAILS
  static Future<Map<String, dynamic>> getTournament(
      String tournamentId) async {

    final response = await ApiService.get(
        "${ApiService.baseUrl}/api/tournaments/$tournamentId");

    return response["data"];
  }

  /// GET MATCHES
  static Future<List<dynamic>> getMatches(
      String tournamentId) async {

    final response = await ApiService.get(
        "${ApiService.baseUrl}/api/tournaments/$tournamentId/matches");

    return response["data"];
  }

  /// GET STANDINGS
  static Future<List<dynamic>> getStandings(
      String tournamentId) async {

    final response = await ApiService.get(
        "${ApiService.baseUrl}/api/tournaments/$tournamentId/standings");

    return response["data"];
  }

  static Future<List<dynamic>> getAllTournaments() async {
    final response = await ApiService.get(
        "${ApiService.baseUrl}/api/tournaments");

    return response["data"];
  }

  static Future<void> finishMatch(
      String matchId,
      int scoreHome,
      int scoreAway,
      ) async {
    await ApiService.post(
      "/api/tournament-matches/$matchId/finish",
      {
        "scoreHome": scoreHome,
        "scoreAway": scoreAway,
      },
    );
  }
}
