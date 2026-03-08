import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/team_full_profile.dart';
import 'package:team_up_fe_new/models/team_statistics.dart';
import 'package:team_up_fe_new/models/team_tournament_history.dart';
import 'package:team_up_fe_new/services/team_api.dart';

class TeamStatisticsPage extends StatefulWidget {
  final String teamId;

  const TeamStatisticsPage({super.key, required this.teamId});

  @override
  State<TeamStatisticsPage> createState() => _TeamStatisticsPageState();
}

class _TeamStatisticsPageState extends State<TeamStatisticsPage> {
  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  bool isLoading = true;
  TeamFullProfileModel? fullProfile;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      final profile = await TeamApi.getTeamProfile(widget.teamId);
      if (mounted) {
        setState(() {
          fullProfile = profile;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading stats: $e"), backgroundColor: Colors.red.shade900),
        );
      }
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullProfile?.team.name.toUpperCase() ?? "SQUAD",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Data & Metrics",
                  style: TextStyle(
                    color: _accentGreen,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedRating() {
    if (fullProfile == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "SQUAD RATINGS",
              style: TextStyle(
                color: _textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: _cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircularStat("ATT", fullProfile!.team.attackRating, Colors.redAccent),
              _buildCircularStat("MID", fullProfile!.team.midfieldRating, Colors.blueAccent),
              _buildCircularStat("DEF", fullProfile!.team.defenseRating, Colors.amber),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularStat(String label, int value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.white.withOpacity(0.05),
                color: color,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              value.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        )
      ],
    );
  }

  Widget _buildBentoMetrics(TeamStatisticsModel stats) {
    double winRate = stats.played > 0 ? (stats.wins / stats.played) : 0.0;
    int winPercentage = (winRate * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "SEASON OVERVIEW",
              style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                height: 236,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: winRate,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            color: _accentGreen,
                            strokeCap: StrokeCap.round,
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "$winPercentage%",
                                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  "WIN RATE",
                                  style: TextStyle(color: _accentGreen, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "${stats.wins}W - ${stats.draws}D - ${stats.losses}L",
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 236,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildSmallBentoBox("MATCHES", stats.played.toString(), Icons.stadium_rounded, Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildClearGoalsBox(stats.goalsFor, stats.goalsAgainst),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${stats.tournamentsWon} Trophies Won",
                      style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "From ${stats.tournamentsPlayed} tournaments played",
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallBentoBox(String label, String value, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentHistorySection(List<TeamTournamentHistoryModel> history) {
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Center(
          child: Text(
            "No tournaments played yet.",
            style: TextStyle(color: _textSecondary, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "RECENT CAMPAIGNS",
          style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        ...history.map((tourney) {
          bool isWinner = tourney.finalPosition == 1;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isWinner ? Colors.amber.withOpacity(0.4) : Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tourney.tournamentName,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSimpleStatData("W", tourney.wins.toString(), _accentGreen),
                          _buildSimpleStatData("D", tourney.draws.toString(), Colors.grey.shade400),
                          _buildSimpleStatData("L", tourney.losses.toString(), Colors.redAccent),
                          Container(width: 1, height: 16, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 12)),
                          _buildSimpleStatData("GF", tourney.goalsFor.toString(), Colors.cyan),
                          _buildSimpleStatData("GA", tourney.goalsAgainst.toString(), Colors.white54),
                        ],
                      ),
                    ],
                  ),
                ),
                if (tourney.finalPosition > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "#${tourney.finalPosition}",
                          style: TextStyle(
                            color: isWinner ? Colors.amber : Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                          ),
                        ),
                        Text(
                          "Place",
                          style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                else
                  Icon(Icons.tour_rounded, color: Colors.white.withOpacity(0.1), size: 32),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSimpleStatData(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: _bgDark,
        body: Center(child: CircularProgressIndicator(color: _accentGreen)),
      );
    }

    if (fullProfile == null) {
      return Scaffold(
        backgroundColor: _bgDark,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Expanded(child: Center(child: Text("Could not load stats.", style: TextStyle(color: Colors.white)))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentGreen.withOpacity(0.15),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBentoMetrics(fullProfile!.statistics),
                        const SizedBox(height: 32), // Spațiu înainte de rating

                        // AM ADĂUGAT AICI SECȚIUNEA DE RATING
                        _buildDetailedRating(),

                        const SizedBox(height: 32), // Spațiu înainte de istoric
                        _buildTournamentHistorySection(fullProfile!.tournamentHistory),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearGoalsBox(int gf, int ga) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_soccer_rounded, color: Colors.cyan, size: 18),
              const SizedBox(width: 6),
              Text(
                "GOALS",
                style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "For",
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    gf.toString(),
                    style: const TextStyle(color: Colors.cyan, fontSize: 22, fontWeight: FontWeight.w900, height: 1.0),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Against",
                    style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    ga.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.0),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}