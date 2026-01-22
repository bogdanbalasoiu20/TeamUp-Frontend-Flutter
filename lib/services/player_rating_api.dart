import 'package:team_up_fe_new/exceptions/api_service.dart';
import '../models/player_to_rate.dart';
import '../models/player_rating_draft.dart';

class PlayerRatingService {

  static Future<List<PlayerToRateModel>> getPlayersToRate(
      String matchId,
      ) async {
    print("FETCH PLAYERS TO RATE for matchId = $matchId");

    final res = await ApiService.get(
      "${ApiService.baseUrl}/api/matches/$matchId/ratings",
    );

    print("RAW RESPONSE = $res");

    final data = res['data'];

    print("DATA FIELD = $data");

    return (data as List)
        .map((e) => PlayerToRateModel.fromJson(e))
        .toList();
  }


  static Future<void> submitRatings(
      String matchId,
      Map<String, PlayerRatingDraft> drafts,
      ) async {
    final body = drafts.entries
        .map((e) => e.value.toJson(e.key))
        .toList();

    await ApiService.post(
      "/api/matches/$matchId/ratings",
      body,
    );
  }
}
