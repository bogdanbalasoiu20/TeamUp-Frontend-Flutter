import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_up_fe_new/models/tournament.dart';
import 'package:team_up_fe_new/models/tournament_match.dart';
import 'package:team_up_fe_new/models/tournament_standing.dart';
import 'package:team_up_fe_new/services/tournament_api.dart';


class TournamentDetailsPage extends StatefulWidget {
  final String tournamentId;

  const TournamentDetailsPage({super.key, required this.tournamentId});

  @override
  State<TournamentDetailsPage> createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> {
  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  bool isLoading = true;
  TournamentModel? tournament;
  List<TournamentMatchModel> matches = [];
  List<TournamentStandingModel> standings = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        TournamentApi.getTournament(widget.tournamentId),
        TournamentApi.getMatches(widget.tournamentId),
        TournamentApi.getStandings(widget.tournamentId),
      ]);

      if (!mounted) return;

      setState(() {
        tournament = TournamentModel.fromJson(results[0] as Map<String, dynamic>);

        final matchesData = results[1] as List<dynamic>;
        matches = matchesData.map((e) => TournamentMatchModel.fromJson(e)).toList();

        final standingsData = results[2] as List<dynamic>;
        standings = standingsData.map((e) => TournamentStandingModel.fromJson(e)).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading details: $e", style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }
  }

  Future<void> _joinTournament() async {
    try {
      await TournamentApi.joinTournament(widget.tournamentId, "dummy-team-id");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Joined successfully!", style: TextStyle(color: Colors.black)),
          backgroundColor: _accentGreen,
        ),
      );
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to join: $e"), backgroundColor: Colors.red.shade900),
      );
    }
  }

  Future<void> _startTournament() async {
    try {
      await TournamentApi.startTournament(widget.tournamentId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Tournament started!", style: TextStyle(color: Colors.black)),
          backgroundColor: _accentGreen,
        ),
      );
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to start: $e"), backgroundColor: Colors.red.shade900),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: _bgDark,
        body: Center(child: CircularProgressIndicator(color: _accentGreen)),
      );
    }

    if (tournament == null) {
      return Scaffold(
        backgroundColor: _bgDark,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text("Tournament not found", style: TextStyle(color: Colors.white))),
      );
    }

    final bool isOpen = tournament!.status.toUpperCase() == "OPEN";

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bgDark,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A6F4A).withOpacity(0.3),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isOpen ? _accentGreen.withOpacity(0.15) : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isOpen ? _accentGreen : Colors.transparent),
                          ),
                          child: Text(
                            tournament!.status.toUpperCase(),
                            style: TextStyle(
                              color: isOpen ? _accentGreen : _textSecondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament!.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: _textSecondary, size: 18),
                            const SizedBox(width: 8),
                            Text(tournament!.venueName, style: TextStyle(color: _textSecondary, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_month, color: _textSecondary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "${DateFormat("MMM dd").format(tournament!.startsAt)} - ${DateFormat("MMM dd").format(tournament!.endsAt)}",
                              style: TextStyle(color: _textSecondary, fontSize: 16),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),


                        Row(
                          children: [
                            if (isOpen)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _joinTournament,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _cardSurface,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: _accentGreen.withOpacity(0.5)),
                                  ),
                                  child: const Text("JOIN TOURNAMENT", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            if (isOpen) const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _startTournament,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentGreen,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("START TOURNAMENT", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),


                  TabBar(
                    indicatorColor: _accentGreen,
                    labelColor: _accentGreen,
                    unselectedLabelColor: _textSecondary,
                    dividerColor: Colors.white.withOpacity(0.05),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: "STANDINGS"),
                      Tab(text: "MATCHES"),
                    ],
                  ),


                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildStandingsTab(),
                        _buildMatchesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStandingsTab() {
    if (standings.isEmpty) {
      return Center(child: Text("No standings yet.", style: TextStyle(color: _textSecondary)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            headingTextStyle: TextStyle(color: _textSecondary, fontWeight: FontWeight.bold),
            dataTextStyle: const TextStyle(color: Colors.white),
            columns: const [
              DataColumn(label: Text("Team")),
              DataColumn(label: Text("P")),
              DataColumn(label: Text("W")),
              DataColumn(label: Text("D")),
              DataColumn(label: Text("L")),
              DataColumn(label: Text("GD")),
              DataColumn(label: Text("Pts")),
            ],
            rows: standings.map((s) {
              final gd = s.goalsFor - s.goalsAgainst;
              return DataRow(cells: [
                DataCell(Text(s.teamName, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(s.played.toString())),
                DataCell(Text(s.wins.toString())),
                DataCell(Text(s.draws.toString())),
                DataCell(Text(s.losses.toString())),
                DataCell(Text(gd > 0 ? "+$gd" : gd.toString(), style: TextStyle(color: gd > 0 ? _accentGreen : Colors.white))),
                DataCell(Text(s.points.toString(), style: TextStyle(color: _accentGreen, fontWeight: FontWeight.bold, fontSize: 16))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }


  Widget _buildMatchesTab() {
    if (matches.isEmpty) {
      return Center(child: Text("No matches scheduled yet.", style: TextStyle(color: _textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final isFinished = match.status.toUpperCase() == "FINISHED";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Text(
                "Matchday ${match.matchDay}",
                style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      match.homeTeamName,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isFinished ? Colors.black.withOpacity(0.3) : _accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isFinished ? "${match.scoreHome} - ${match.scoreAway}" : "VS",
                      style: TextStyle(
                        color: isFinished ? Colors.white : _accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.awayTeamName,
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}