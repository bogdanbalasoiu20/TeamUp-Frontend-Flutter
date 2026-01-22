import 'package:team_up_fe_new/exceptions/api_service.dart';
import '../widgets/player_card/player_card_ui.dart';

class PlayerCardService {
  static Future<PlayerCardUi> getPlayerCard(String userId) async {
    final response = await ApiService.get(
      "${ApiService.baseUrl}/api/users/$userId/card",
    );

    final data = response['data'];

    return PlayerCardUi(
      name: data['name'],
      position: data['position'],
      rating: data['overall'],
      imageUrl: data['imageUrl'] ??
          "https://i.imgur.com/BoN9kdC.png",
      stats: Map<String, int>.from(data['stats']),
    );
  }
}
