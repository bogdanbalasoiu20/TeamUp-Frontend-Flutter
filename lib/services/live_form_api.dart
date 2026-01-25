import 'package:team_up_fe_new/exceptions/api_service.dart';

import '../models/live_form.dart';

class LiveFormApi {
  static Future<LiveForm> getLiveForm(String userId) async {
    final response = await ApiService.get(
      '${ApiService.baseUrl}/api/users/$userId/card/live-form',
    );

    return LiveForm.fromJson(response['data']);
  }
}
