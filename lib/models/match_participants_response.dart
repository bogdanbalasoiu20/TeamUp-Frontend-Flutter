import 'package:team_up_fe_new/models/participant.dart';

class MatchParticipantsResponse {
  final String creatorId;
  final List<Participant> participants;

  MatchParticipantsResponse({
    required this.creatorId,
    required this.participants,
  });

  factory MatchParticipantsResponse.fromJson(Map<String, dynamic> json) {
    final participantPage = json["participants"];
    final content = participantPage["content"] as List;

    return MatchParticipantsResponse(
      creatorId: json["creatorId"],
      participants: content.map((e) => Participant.fromJson(e)).toList(),
    );
  }
}
