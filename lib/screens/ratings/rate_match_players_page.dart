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

  @override
  void initState() {
    super.initState();
    _playersFuture = PlayerRatingService.getPlayersToRate(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    int ratedCount = _drafts.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF003B2F),
            Color(0xFF0A6F4A),
            Color(0xFF062D24),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,

        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.1),
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          title: const Text(
            "Rate Players",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 8, color: Colors.black45, offset: Offset(0, 2)),
              ],
            ),
          ),
        ),

        body: Column(
          children: [
            // ---------------- LISTA JUCĂTORI ----------------
            Expanded(
              child: FutureBuilder<List<PlayerToRateModel>>(
                future: _playersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final players = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
                    itemCount: players.length,
                    itemBuilder: (_, i) {
                      final p = players[i];
                      final isRated = _drafts.containsKey(p.userId);

                      return _buildPlayerCard(p, isRated);
                    },
                  );
                },
              ),
            ),

            _buildBottomBar(ratedCount),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(PlayerToRateModel p, bool isRated) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: InkWell(
            onTap: () => _openRatingSheet(p),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRated
                    ? const Color(0xFF46C264).withOpacity(0.15)
                    : Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isRated
                      ? const Color(0xFF46C264).withOpacity(0.6)
                      : Colors.white.withOpacity(0.15),
                  width: isRated ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p.username.isNotEmpty ? p.username[0].toUpperCase() : "?",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.sports_soccer,
                                size: 14, color: Colors.white.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text(
                              p.position,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isRated
                          ? const Color(0xFF46C264)
                          : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRated ? Icons.check : Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline, size: 50, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  "No players to rate found.",
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Zona de jos cu butonul de submit
  Widget _buildBottomBar(int ratedCount) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Container(
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A6F4A), Color(0xFF46C264)],
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: isSubmitting
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      "Submit ($ratedCount) Ratings",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openRatingSheet(PlayerToRateModel player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0E1B16),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: RatingFormSheet(
                player: player,
                draft: _drafts[player.userId],
                onSave: (draft) {
                  setState(() {
                    _drafts[player.userId] = draft;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_drafts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please rate at least one player"),
          backgroundColor: Colors.white.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
          action: SnackBarAction(label: "OK", textColor: Colors.black, onPressed: () {}),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await PlayerRatingService.submitRatings(
        widget.matchId,
        _drafts,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ratings submitted successfully!"),
          backgroundColor: Color(0xFF0A6F4A),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting ratings")),
      );
    } finally {
      if(mounted) setState(() => isSubmitting = false);
    }
  }
}