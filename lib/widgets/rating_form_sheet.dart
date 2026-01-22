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

  // Culorile temei
  final Color _activeColor = const Color(0xFF46C264);
  final Color _inactiveColor = Colors.white24;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? PlayerRatingDraft();
  }

  // --------------------------------------------------
  //SLIDER
  // --------------------------------------------------
  Widget _statSlider(
      String label,
      int? value,
      void Function(int) onChanged,
      ) {
    final v = value ?? 50;

    Color valueColor;
    if (v < 50) {
      valueColor = Colors.white70;
    } else if (v < 80) {
      valueColor = const Color(0xFF81C784); // Light Green
    } else {
      valueColor = const Color(0xFF46C264); // Brand Green
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + Value Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: valueColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: valueColor.withOpacity(0.3)),
                ),
                child: Text(
                  v.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // The Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: _activeColor,
              inactiveTrackColor: _inactiveColor,
              thumbColor: Colors.white,
              overlayColor: _activeColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              min: 0,
              max: 99,
              divisions: 99,
              value: v.toDouble(),
              onChanged: (newValue) =>
                  setState(() => onChanged(newValue.round())),
            ),
          ),
        ],
      ),
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

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E1B16), // Dark background matching the theme
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar (linia mică de sus)
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isGk ? Icons.sports_handball : Icons.sports_soccer,
                    color: const Color(0xFF46C264),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rate Player",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      widget.player.username,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(color: Colors.white12),
            const SizedBox(height: 20),

            // Stats List
            ...(isGk ? _buildGkStats() : _buildFieldStats()),

            const SizedBox(height: 10),

            // Save Button (Gradient style)
            Container(
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A6F4A), Color(0xFF46C264)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_draft);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Save Rating",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}