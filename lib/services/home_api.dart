import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/models/home_upcoming.dart';


class HomeApi {

  static Future<HomeUpcomingModel> getUpcoming() async {
    final response = await ApiService.get(
      "${ApiService.baseUrl}/api/home/upcoming",
    );

    print("HOME API RESPONSE: $response");
    final data = response["data"];

    return HomeUpcomingModel.fromJson(data);
  }
}