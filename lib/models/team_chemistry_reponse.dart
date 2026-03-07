import 'package:team_up_fe_new/models/team_chemistry_link.dart';

class TeamChemistryResponseModel {
  final int teamChemistry;
  final List<TeamChemistryLinkModel> links;

  TeamChemistryResponseModel({
    required this.teamChemistry,
    required this.links,
  });

  factory TeamChemistryResponseModel.fromJson(Map<String, dynamic> json) {
    return TeamChemistryResponseModel(
      teamChemistry: json["teamChemistry"],
      links: (json["links"] as List)
          .map((e) => TeamChemistryLinkModel.fromJson(e))
          .toList(),
    );
  }
}