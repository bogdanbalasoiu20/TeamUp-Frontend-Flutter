import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:team_up_fe_new/models/tournament.dart';
import 'package:team_up_fe_new/models/tournament_match.dart';
import 'package:team_up_fe_new/models/tournament_standing.dart';
import 'package:team_up_fe_new/models/team.dart';
import 'package:team_up_fe_new/services/tournament_api.dart';
import 'package:team_up_fe_new/services/team_api.dart';
import 'package:team_up_fe_new/widgets/finish_match_dialog.dart';

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
  String? currentUsername;
  String? joinedTeamName;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUsername = prefs.getString("username");

      final results = await Future.wait([
        TournamentApi.getTournament(widget.tournamentId),
        TournamentApi.getMatches(widget.tournamentId),
        TournamentApi.getStandings(widget.tournamentId),
        TeamApi.getMyTeams().catchError((_) => <TeamModel>[]),
      ]);

      if (!mounted) return;

      setState(() {
        tournament = TournamentModel.fromJson(results[0] as Map<String, dynamic>);

        final matchesData = results[1] as List<dynamic>;
        matches = matchesData.map((e) => TournamentMatchModel.fromJson(e)).toList();

        matches.sort((a, b) {
          int dayComparison = a.matchDay.compareTo(b.matchDay);
          if (dayComparison != 0) {
            return dayComparison;
          }
          return a.homeTeamName.compareTo(b.homeTeamName);
        });

        final standingsData = results[2] as List<dynamic>;
        standings = standingsData.map((e) => TournamentStandingModel.fromJson(e)).toList();

        final myTeams = results[3] as List<TeamModel>;

        joinedTeamName = null;
        for (var myTeam in myTeams) {
          if (standings.any((s) => s.teamName == myTeam.name)) {
            joinedTeamName = myTeam.name;
            break;
          }
        }

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

  void _openJoinModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SelectTeamToJoinModal(
        tournamentId: widget.tournamentId,
        onTeamJoined: () {
          _fetchData();
        },
      ),
    );
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

  String _formatDateRange(DateTime start, DateTime end) {
    final bool sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
    if (sameDay) {
      return "${DateFormat("MMM dd, HH:mm").format(start)} - ${DateFormat("HH:mm").format(end)}";
    }
    return "${DateFormat("MMM dd, HH:mm").format(start)}  -  ${DateFormat("MMM dd, HH:mm").format(end)}";
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
                  "TOURNAMENT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Details",
                  style: TextStyle(
                    color: _accentGreen,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (tournament != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tournament!.status.toUpperCase() == "OPEN" ? _accentGreen.withOpacity(0.15) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: tournament!.status.toUpperCase() == "OPEN" ? _accentGreen.withOpacity(0.5) : Colors.transparent),
              ),
              child: Text(
                tournament!.status.toUpperCase(),
                style: TextStyle(
                  color: tournament!.status.toUpperCase() == "OPEN" ? _accentGreen : _textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final double mapLat = tournament!.venueLatitude;
    final double mapLng = tournament!.venueLongitude;

    return Container(
      height: 140,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accentGreen, width: 2),
        color: _cardSurface,
        boxShadow: [
          BoxShadow(
            color: _accentGreen.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(mapLat, mapLng),
            zoom: 15,
            interactiveFlags: InteractiveFlag.none,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.teamup.app",
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(mapLat, mapLng),
                  width: 40,
                  height: 40,
                  builder: (_) => Icon(
                    Icons.location_on,
                    color: _accentGreen,
                    size: 36,
                    shadows: const [Shadow(blurRadius: 8, color: Colors.black87)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isOpen, bool isCreator) {
    if (joinedTeamName != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: _accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _accentGreen.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: _accentGreen, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Joined with $joinedTeamName",
                      style: TextStyle(color: _accentGreen, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (isOpen) {
      if (isCreator) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _openJoinModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardSurface,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: _accentGreen.withOpacity(0.3)),
                ),
                child: const Text("JOIN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _startTournament,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentGreen,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("START TOURNAMENT", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 240,
              child: ElevatedButton(
                onPressed: _openJoinModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentGreen,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("JOIN TOURNAMENT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildTournamentHeaderInfo(bool isOpen, bool isCreator) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMapSection(),

          Text(
            tournament!.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.location_on_rounded, color: _textSecondary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tournament!.venueName,
                  style: TextStyle(color: _textSecondary, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.calendar_month_rounded, color: _textSecondary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatDateRange(tournament!.startsAt, tournament!.endsAt),
                  style: TextStyle(color: _textSecondary, fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildActionButtons(isOpen, isCreator),

          const SizedBox(height: 8),
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

    if (tournament == null) {
      return Scaffold(
        backgroundColor: _bgDark,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Expanded(child: Center(child: Text("Tournament not found", style: TextStyle(color: Colors.white)))),
            ],
          ),
        ),
      );
    }

    final bool isOpen = tournament!.status.toUpperCase() == "OPEN";
    final bool isCreator = tournament!.creatorUsername == currentUsername;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bgDark,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A6F4A).withOpacity(0.2),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(),
                          _buildTournamentHeaderInfo(isOpen, isCreator),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          indicatorColor: _accentGreen,
                          labelColor: _accentGreen,
                          unselectedLabelColor: _textSecondary,
                          dividerColor: Colors.white.withOpacity(0.05),
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          tabs: const [
                            Tab(text: "STANDINGS"),
                            Tab(text: "MATCHES"),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _buildStandingsTab(),
                    _buildMatchesTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingsTab() {
    if (standings.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _accentGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          size: 48,
                          color: _accentGreen,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "No Teams Enrolled",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "The leaderboard will appear here once teams start joining the tournament.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            headingTextStyle: TextStyle(color: _textSecondary, fontWeight: FontWeight.bold, fontSize: 12),
            dataTextStyle: const TextStyle(color: Colors.white),
            columns: const [
              DataColumn(label: Text("TEAM")),
              DataColumn(label: Text("P")),
              DataColumn(label: Text("W")),
              DataColumn(label: Text("D")),
              DataColumn(label: Text("L")),
              DataColumn(label: Text("GD")),
              DataColumn(label: Text("PTS")),
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
                DataCell(Text(s.points.toString(), style: TextStyle(color: _accentGreen, fontWeight: FontWeight.w900, fontSize: 16))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgePlaceholder() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _bgDark,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Center(
        child: Icon(Icons.shield, color: _textSecondary.withOpacity(0.5), size: 16),
      ),
    );
  }

  Widget _buildMatchesTab() {
    if (matches.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _accentGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 48,
                          color: _accentGreen,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Schedule Pending",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "The match schedule will be automatically generated and displayed here once the tournament officially starts.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    final bool isCreator = tournament?.creatorUsername == currentUsername;

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final isFinished = match.status.toUpperCase() == "FINISHED" || match.status.toUpperCase() == "DONE";
        final bool isFirstInMatchDay = index == 0 || matches[index - 1].matchDay != match.matchDay;

        Widget matchCard = Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            match.homeTeamName,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildBadgePlaceholder(),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isFinished ? Colors.black.withOpacity(0.3) : _bgDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isFinished ? Colors.white.withOpacity(0.05) : _accentGreen.withOpacity(0.3)),
                    ),
                    child: Text(
                      isFinished ? "${match.scoreHome} - ${match.scoreAway}" : "VS",
                      style: TextStyle(
                        color: isFinished ? Colors.white : _accentGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildBadgePlaceholder(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            match.awayTeamName,
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (isCreator && !isFinished) ...[
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.05), height: 1),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    showFinishMatchDialog(
                      context: context,
                      match: match,
                      onMatchFinished: () {
                        _fetchData();
                      },
                    );
                  },
                  icon: Icon(Icons.edit_note_rounded, color: _accentGreen, size: 20),
                  label: Text(
                    "ENTER SCORE",
                    style: TextStyle(color: _accentGreen, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        );

        if (isFirstInMatchDay) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index != 0) const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 8),
                child: Text(
                  "ROUND ${match.matchDay}",
                  style: TextStyle(
                    color: _accentGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              matchCard,
            ],
          );
        }

        return matchCard;
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF091210),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}

class _SelectTeamToJoinModal extends StatefulWidget {
  final String tournamentId;
  final VoidCallback onTeamJoined;

  const _SelectTeamToJoinModal({required this.tournamentId, required this.onTeamJoined});

  @override
  State<_SelectTeamToJoinModal> createState() => _SelectTeamToJoinModalState();
}

class _SelectTeamToJoinModalState extends State<_SelectTeamToJoinModal> {
  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);

  List<TeamModel> myCaptainTeams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUsername = prefs.getString("username");

      final teams = await TeamApi.getMyTeams();

      if (mounted) {
        setState(() {
          myCaptainTeams = teams.where((t) => t.captainUsername == currentUsername).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _joinWithTeam(String teamId) async {
    try {
      await TournamentApi.joinTournament(widget.tournamentId, teamId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Team joined successfully!", style: TextStyle(color: Colors.black)), backgroundColor: _accentGreen),
        );
        widget.onTeamJoined();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to join: $e"), backgroundColor: Colors.red.shade900),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: _bgDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Select Team to Join",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "You can only enroll teams you captain.",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: _accentGreen))
                : myCaptainTeams.isEmpty
                ? Center(
              child: Text(
                "You are not the captain of any team.\nCreate a team first!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            )
                : ListView.builder(
              itemCount: myCaptainTeams.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, i) {
                final team = myCaptainTeams[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _accentGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shield_rounded, color: _accentGreen),
                    ),
                    title: Text(
                      team.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Rating: ${team.teamRating.toStringAsFixed(1)}",
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _joinWithTeam(team.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Enroll", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}