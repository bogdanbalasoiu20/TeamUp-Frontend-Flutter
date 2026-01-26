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

  int _selectedTabIndex = 0;

  final Color _activeColor = const Color(0xFF46C264);
  final Color _inactiveColor = Colors.white24;

  @override
  void initState() {
    super.initState();

    if (widget.draft != null) {
      _draft = widget.draft!.copy();
    } else {
      _draft = PlayerRatingDraft();
      if (widget.player.position == "GOALKEEPER") {
        _draft
          ..gkDiving = 50
          ..gkHandling = 50
          ..gkKicking = 50
          ..gkReflexes = 50
          ..gkSpeed = 50
          ..gkPositioning = 50;
      } else {
        _draft
          ..pace = 50
          ..shooting = 50
          ..passing = 50
          ..defending = 50
          ..dribbling = 50
          ..physical = 50;
      }

      _draft
        ..fairPlay ??= 50
        ..communication ??= 50
        ..fun ??= 50
        ..competitiveness ??= 50
        ..adaptability ??= 50
        ..reliability ??= 50;
    }
  }

  Widget _buildTabSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabButton("Skills", 0),
          _buildTabButton("Behavior", 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

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
      valueColor = const Color(0xFF81C784);
    } else {
      valueColor = const Color(0xFF46C264);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  List<Widget> _buildGkStats() {
    return [
      _statSlider("Diving", _draft.gkDiving, (v) => _draft.gkDiving = v),
      _statSlider("Handling", _draft.gkHandling, (v) => _draft.gkHandling = v),
      _statSlider("Kicking", _draft.gkKicking, (v) => _draft.gkKicking = v),
      _statSlider("Reflexes", _draft.gkReflexes, (v) => _draft.gkReflexes = v),
      _statSlider("Speed", _draft.gkSpeed, (v) => _draft.gkSpeed = v),
      _statSlider("Positioning", _draft.gkPositioning,
              (v) => _draft.gkPositioning = v),
    ];
  }

  List<Widget> _buildBehaviorStats() {
    return [
      const SizedBox(height: 8),
      _statSlider("Fair Play", _draft.fairPlay, (v) => _draft.fairPlay = v),
      _statSlider("Communication", _draft.communication,
              (v) => _draft.communication = v),
      _statSlider("Fun", _draft.fun, (v) => _draft.fun = v),
      _statSlider("Competitiveness", _draft.competitiveness,
              (v) => _draft.competitiveness = v),
      _statSlider("Adaptability", _draft.adaptability,
              (v) => _draft.adaptability = v),
      _statSlider("Reliability", _draft.reliability,
              (v) => _draft.reliability = v),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isGk = widget.player.position == "GOALKEEPER";

    List<Widget> currentStats;
    if (_selectedTabIndex == 0) {
      currentStats = isGk ? _buildGkStats() : _buildFieldStats();
    } else {
      currentStats = _buildBehaviorStats();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E1B16),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Drag Handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rate Player",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
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
              ),
            ],
          ),

          _buildTabSwitch(),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...currentStats,
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.only(top: 10),
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
    );
  }
}