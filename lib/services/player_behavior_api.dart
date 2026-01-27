import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/widgets/player_behavior_ui.dart';

class PlayerBehaviorService {
  static Future<PlayerBehaviorUi> getBehaviorStats(String userId) async {
    final response = await ApiService.get(
      "${ApiService.baseUrl}/api/users/$userId/behavior-stats",
    );

    final data = response['data'];

    return PlayerBehaviorUi.fromJson(data);
  }
}
