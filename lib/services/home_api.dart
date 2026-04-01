import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/models/home_model.dart';


class HomeApi {

  static Future<HomeResponse> getHome() async {
    final response = await ApiService.get(
      "${ApiService.baseUrl}/api/home",
    );

    print("HOME API RESPONSE: $response");

    return HomeResponse.fromJson(response);
  }
}