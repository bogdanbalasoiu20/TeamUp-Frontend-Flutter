import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/models/chemistry_result.dart';
import 'package:team_up_fe_new/models/team_chemistry_reponse.dart';


class ChemistryApi {
  static Future<ChemistryResult> getChemistry(String otherUserId) async {
    final response = await ApiService.get(
      "${ApiService.baseUrl}/chemistry/$otherUserId",
    );

    return ChemistryResult.fromJson(response['data']);
  }

  static Future<TeamChemistryResponseModel> getTeamChemistry(String teamId) async {
    final response = await ApiService.get("${ApiService.baseUrl}/chemistry/$teamId/chemistry");

    return TeamChemistryResponseModel.fromJson(response["data"]);
  }
}
