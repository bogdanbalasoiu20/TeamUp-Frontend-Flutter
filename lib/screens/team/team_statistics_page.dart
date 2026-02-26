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
          SnackBar(
            content: Text("Error loading stats: $e"),
            backgroundColor: Colors.red.shade900,
          ),
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
                const Text(
                  "TEAM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Statistics",
                  style: TextStyle(
                    color: _accentGreen,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatBox(String label, String value, IconData icon, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? Colors.amber.withOpacity(0.1) : _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlight ? Colors.amber.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: highlight ? Colors.amber : _textSecondary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: highlight ? Colors.amber : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: _textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(TeamStatisticsModel stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "OVERALL PERFORMANCE",
          style: TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMiniStatBox("MATCHES", stats.played.toString(), Icons.sports_soccer)),
            const SizedBox(width: 12),
            Expanded(child: _buildMiniStatBox("GOALS (F-A)", "${stats.goalsFor} - ${stats.goalsAgainst}", Icons.sports_score)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMiniStatBox("TOURNAMENTS", stats.tournamentsPlayed.toString(), Icons.flag_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildMiniStatBox("TROPHIES", stats.tournamentsWon.toString(), Icons.emoji_events, highlight: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildTournamentHistorySection(List<TeamTournamentHistoryModel> history) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text("No tournament history yet.", style: TextStyle(color: _textSecondary, fontStyle: FontStyle.italic)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TOURNAMENT HISTORY",
          style: TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        ...history.map((tourney) {
          bool isWinner = tourney.finalPosition == 1;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isWinner ? Colors.amber.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isWinner ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isWinner ? Icons.emoji_events_rounded : Icons.tour_rounded,
                    color: isWinner ? Colors.amber : _textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tourney.tournamentName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "W: ${tourney.wins} | D: ${tourney.draws} | L: ${tourney.losses}\nGF/GA: ${tourney.goalsFor}/${tourney.goalsAgainst}",
                        style: TextStyle(color: _textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tourney.finalPosition > 0 ? "#${tourney.finalPosition}" : "-",
                      style: TextStyle(
                        color: isWinner ? Colors.amber : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Place",
                      style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
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
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullProfile!.team.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildPerformanceSection(fullProfile!.statistics),
                    const SizedBox(height: 40),
                    _buildTournamentHistorySection(fullProfile!.tournamentHistory),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}