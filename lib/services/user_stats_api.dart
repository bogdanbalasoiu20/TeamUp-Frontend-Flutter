import 'package:team_up_fe_new/exceptions/api_service.dart';
import '../models/user_stats.dart';

class UserStatsApi {
  static Future<UserStats> getUserStats(String userId) async {
    final response = await ApiService.get(
      "${ApiService.baseUrl}/api/users/$userId/stats",
    );

    return UserStats.fromJson(response['data']);
  }
}
