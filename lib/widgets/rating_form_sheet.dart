import 'package:flutter/material.dart';
import '../models/player_to_rate.dart';
import '../models/player_rating_draft.dart';

class RatingFormSheet extends StatefulWidget {
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
  State<RatingFormSheet> createState() => _RatingFormSheetState();
}

class _RatingFormSheetState extends State<RatingFormSheet> {
  late PlayerRatingDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? PlayerRatingDraft();
  }

  // --------------------------------------------------
  // GENERIC SLIDER
  // --------------------------------------------------
  Widget _statSlider(
      String label,
      int? value,
      void Function(int) onChanged,
      ) {
    final v = value ?? 50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: $v",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          min: 0,
          max: 99,
          divisions: 99,
          value: v.toDouble(),
          onChanged: (newValue) =>
              setState(() => onChanged(newValue.round())),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // --------------------------------------------------
  // FIELD PLAYER STATS
  // --------------------------------------------------
  List<Widget> _buildFieldStats() {
    return [
      _statSlider("Pace", _draft.pace, (v) => _draft.pace = v),
      _statSlider("Shooting", _draft.shooting, (v) => _draft.shooting = v),
      _statSlider("Passing", _draft.passing, (v) => _draft.passing = v),
      _statSlider("Dribbling", _draft.dribbling, (v) => _draft.dribbling = v),
      _statSlider("Defending", _draft.defending, (v) => _draft.defending = v),
      _statSlider("Physical", _draft.physical, (v) => _draft.physical = v),
    ];
  }

  // --------------------------------------------------
  // GOALKEEPER STATS
  // --------------------------------------------------
  List<Widget> _buildGkStats() {
    return [
      _statSlider("Diving", _draft.gkDiving, (v) => _draft.gkDiving = v),
      _statSlider("Handling", _draft.gkHandling, (v) => _draft.gkHandling = v),
      _statSlider("Kicking", _draft.gkKicking, (v) => _draft.gkKicking = v),
      _statSlider("Reflexes", _draft.gkReflexes, (v) => _draft.gkReflexes = v),
      _statSlider("Speed", _draft.gkSpeed, (v) => _draft.gkSpeed = v),
      _statSlider(
          "Positioning", _draft.gkPositioning, (v) => _draft.gkPositioning = v),
    ];
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isGk = widget.player.position == "GOALKEEPER";

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Rate ${widget.player.username}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ...(isGk ? _buildGkStats() : _buildFieldStats()),

            const SizedBox(height: 20),


            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_draft);
                  Navigator.pop(context);
                },
                child: const Text("Save Rating"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
