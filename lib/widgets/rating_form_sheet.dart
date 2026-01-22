import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/player_rating_draft.dart';
import 'package:team_up_fe_new/models/player_to_rate.dart';

class RatingFormSheet extends StatelessWidget {
  final PlayerToRateModel player;
  final PlayerRatingDraft? draft;
  final void Function(PlayerRatingDraft) onSave;

  const RatingFormSheet({
    super.key,
    required this.player,
    this.draft,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Rate ${player.username}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              onSave(PlayerRatingDraft());
              Navigator.pop(context);
            },
            child: const Text("Save (temporary)"),
          ),
        ],
      ),
    );
  }
}


