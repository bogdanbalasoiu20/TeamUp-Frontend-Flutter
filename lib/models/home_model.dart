import 'package:team_up_fe_new/models/home_upcoming.dart';
import 'package:team_up_fe_new/models/home_user_stats.dart';
import 'package:team_up_fe_new/models/monthly_stats.dart';

class HomeResponse {
  final HomeUpcomingModel upcoming;
  final MonthlyStats stats;
  final UserHomeStats userStats;

  HomeResponse({
    required this.upcoming,
    required this.stats,
    required this.userStats,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"];

    return HomeResponse(
      upcoming: HomeUpcomingModel.fromJson(data["homeUpcomingResponse"]),
      stats: MonthlyStats.fromJson(data["monthlyStats"]),
      userStats: UserHomeStats.fromJson(data["userStats"]),
    );
  }
}