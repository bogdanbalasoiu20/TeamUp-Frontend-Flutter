import 'package:team_up_fe_new/models/home_upcoming.dart';
import 'package:team_up_fe_new/models/monthly_stats.dart';

class HomeResponse {
  final HomeUpcomingModel upcoming;
  final MonthlyStats stats;

  HomeResponse({
    required this.upcoming,
    required this.stats,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"];

    return HomeResponse(
      upcoming: HomeUpcomingModel.fromJson(data["homeUpcomingResponse"]),
      stats: MonthlyStats.fromJson(data["monthlyStats"]),
    );
  }
}