import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/player_rating_draft.dart';
import 'package:team_up_fe_new/models/player_to_rate.dart';
import 'package:team_up_fe_new/services/player_rating_api.dart';
import 'package:team_up_fe_new/widgets/rating_form_sheet.dart';

class RateMatchPlayersPage extends StatefulWidget {
  final String matchId;

  const RateMatchPlayersPage({super.key, required this.matchId});

  @override
  State<RateMatchPlayersPage> createState() => _RateMatchPlayersPageState();
}

class _RateMatchPlayersPageState extends State<RateMatchPlayersPage> {
  late Future<List<PlayerToRateModel>> _playersFuture;
  final Map<String, PlayerRatingDraft> _drafts = {};
  bool isSubmitting = false;

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  @override
  void initState() {
    super.initState();
    _playersFuture = PlayerRatingService.getPlayersToRate(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: FutureBuilder<List<PlayerToRateModel>>(
        future: _playersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _accentGreen));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final players = snapshot.data!;
          final ratedCount = _drafts.length;
          final totalPlayers = players.length;
          final progress = totalPlayers > 0 ? ratedCount / totalPlayers : 0.0;

          return Stack(
            children: [
              // Background Ambient Gradient
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0A6F4A).withOpacity(0.4)
                  ),
                ),
              ),

              Column(
                children: [
                  // CUSTOM HEADER & PROGRESS
                  _buildHeader(ratedCount, totalPlayers, progress),

                  // PLAYERS LIST
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: players.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final p = players[i];
                        final isRated = _drafts.containsKey(p.userId);
                        return _buildModernPlayerCard(p, isRated);
                      },
                    ),
                  ),

                  //SUBMIT BUTTON AREA
                  _buildBottomDock(ratedCount),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int rated, int total, double progress) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Match Ratings",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Who was the MVP today?",
                      style: TextStyle(
                        fontSize: 14,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Close button icon
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Progress Bar Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  // Circular Percent
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          color: _accentGreen,
                          strokeWidth: 4,
                        ),
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$rated of $total Players Rated",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        rated == total ? "All done! Ready to submit." : "Keep going!",
                        style: TextStyle(
                          color: rated == total ? _accentGreen : _textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPlayerCard(PlayerToRateModel p, bool isRated) {
    return GestureDetector(
      onTap: () => _openRatingSheet(p),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRated ? const Color(0xFF0F3025) : _cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRated ? _accentGreen.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // AVATAR
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isRated
                      ? [_accentGreen, const Color(0xFF008C4A)]
                      : [Colors.grey.shade700, Colors.grey.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cardSurface,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    p.username.isNotEmpty ? p.username.substring(0, 1).toUpperCase() : "?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isRated ? _accentGreen : Colors.white70,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p.position.toUpperCase(),
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            isRated
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: _accentGreen, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "RATED",
                    style: TextStyle(
                      color: _accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
                : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Icon(Icons.edit, color: Colors.black, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomDock(int ratedCount) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: _bgDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentGreen,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            disabledBackgroundColor: _cardSurface,
            disabledForegroundColor: Colors.white30,
          ),
          child: isSubmitting
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
          )
              : Text(
            "Submit Ratings ($ratedCount)",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("No players found", style: TextStyle(color: Colors.white)));

  void _openRatingSheet(PlayerToRateModel player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, c) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E1B16),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: RatingFormSheet(
            player: player,
            draft: _drafts[player.userId],
            onSave: (draft) => setState(() => _drafts[player.userId] = draft),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_drafts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rate at least one player")));
      return;
    }
    setState(() => isSubmitting = true);
    try {
      await PlayerRatingService.submitRatings(widget.matchId, _drafts);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error")));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }
}