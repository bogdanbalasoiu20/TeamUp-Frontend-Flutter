import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/models/home_model.dart';

import 'package:team_up_fe_new/models/upcoming_match.dart';
import 'package:team_up_fe_new/models/upcoming_tournament.dart';
import 'package:team_up_fe_new/screens/match_participants/match_participants_page.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';
import 'package:team_up_fe_new/screens/tournament/tournament_details_page.dart';
import 'package:team_up_fe_new/services/home_api.dart';

import 'package:team_up_fe_new/screens/matches/finish_match_screen.dart';
import 'package:team_up_fe_new/services/match_api.dart';

import 'package:team_up_fe_new/screens/notifications/notifications_page.dart';
import 'package:team_up_fe_new/services/notifications_api.dart';
import 'package:team_up_fe_new/widgets/left_menu_modal.dart';
import 'package:team_up_fe_new/widgets/top_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _finishScreenOpened = false;
  bool _checkingFinishMatch = false;

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  bool _isLoading = true;
  HomeResponse? _data;
  String _username = "Player";

  int unseenCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFinishMatchPrompt();
    });

    _loadUserAndData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkFinishMatchPrompt();
    }
  }

  Future<void> _checkFinishMatchPrompt() async {
    if (_finishScreenOpened || _checkingFinishMatch) return;

    _checkingFinishMatch = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      if (token == null) return;

      final pending = await MatchApi.getOldestFinishPendingMatch();
      if (pending == null) return;

      final match = await MatchApi.fetchMatchDetails(pending.id);

      _finishScreenOpened = true;

      if (!mounted) return;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => FinishMatchScreen(match: match),
        ),
      );

      _finishScreenOpened = false;

      if (result == true) {
        _checkFinishMatchPrompt();
      }
    } catch (e) {
      debugPrint("Finish match check failed: $e");
    } finally {
      _checkingFinishMatch = false;
    }
  }

  Future<void> _loadUnseen() async {
    try {
      final all = await NotificationsApi.fetchAll();
      final count = all.where((n) => !n.isSeen).length;
      if (mounted) setState(() => unseenCount = count);
    } catch (_) {}
  }

  Future<void> _loadUserAndData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString("username");
      if (savedUser != null) {
        _username = savedUser;
      }

      await Future.wait([
        _loadUnseen(),
        HomeApi.getHome().then((data) {
          if (mounted) {
            setState(() {
              _data = data;
            });
          }
        }),
      ]);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading dashboard: $e"),
            backgroundColor: Colors.red.shade900,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopSheetBar(
              unseenCount: unseenCount,
              onNotificationsTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
                _loadUnseen();
              },
              onMenuTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final user = prefs.getString("username");
                if (user != null && mounted) showLeftMenuModal(context, user);
              },
            ),

            Expanded(
              child: RefreshIndicator(
                color: _accentGreen,
                backgroundColor: _cardSurface,
                onRefresh: _loadUserAndData,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: _accentGreen))
                    : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildContent(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = "Good evening";
    if (hour < 12) {
      greeting = "Good morning";
    } else if (hour < 18) {
      greeting = "Good afternoon";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              greeting,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),

          ],
        ),
        const SizedBox(height: 6),
        Text(
          _username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          "Ready for your next match?",
          style: TextStyle(
            color: _accentGreen,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final matches = _data?.upcoming.matches ?? [];
    final tournaments = _data?.upcoming.tournaments ?? [];
    final stats = _data?.stats;
    final userStats = _data?.userStats;

    if (matches.isEmpty && tournaments.isEmpty && stats == null) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (stats != null || userStats != null) ...[
          _buildSectionTitle("MY DASHBOARD"),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfilePill(userStats),

                const SizedBox(width: 16),

                Expanded(child: _buildCompactStatsCard(stats)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // --- NEXT MATCHES ---
        if (matches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle("NEXT MATCHES"),
              Text(
                  "${matches.length} scheduled",
                  style: TextStyle(color: _accentGreen, fontSize: 11, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: matches.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildHorizontalMatchCard(matches[index]);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // --- UPCOMING TOURNAMENTS ---
        if (tournaments.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle("UPCOMING TOURNAMENTS"),
              Text(
                  "${tournaments.length} joined",
                  style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: tournaments.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildHorizontalTournamentCard(tournaments[index]);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: _textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildProfilePill(dynamic userStats) {
    if (userStats == null) {
      return Container(
        width: 110,
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: CircularProgressIndicator(color: _accentGreen)),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfilePage(username: _username))
        );
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5)
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accentGreen.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: _accentGreen.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1
                    )
                  ]
              ),
              child: ClipOval(
                child: (userStats.avatarUrl != null && userStats.avatarUrl!.isNotEmpty)
                    ? Image.network(
                  "${userStats.avatarUrl!}?t=${DateTime.now().millisecondsSinceEpoch}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.person_rounded, color: _textSecondary, size: 35),
                )
                    : Icon(Icons.person_rounded, color: _textSecondary, size: 35),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  userStats.rating.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.0),
                ),
                if (userStats.ratingChange != 0) ...[
                  const SizedBox(width: 4),
                  Icon(
                    userStats.ratingChange > 0 ? Icons.north_east_rounded : Icons.south_east_rounded,
                    color: userStats.ratingChange > 0 ? _accentGreen : Colors.redAccent,
                    size: 12,
                  ),
                  Text(
                    userStats.ratingChange.abs().toString(),
                    style: TextStyle(
                      color: userStats.ratingChange > 0 ? _accentGreen : Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              userStats.position ?? "N/A",
              style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatsCard(dynamic stats) {
    if (stats == null) return const SizedBox();

    final bool isPositiveTrend = stats.percentageChange >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- TOP: TOTAL ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Textul are acum tot spațiul din lume
              Text(
                "ACTIVITY THIS MONTH",
                style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),

              // Numărul și procentajul stau frumos unul lângă altul
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, // Le aliniem pe centru vertical
                children: [
                  Text(
                    stats.totalThisMonth.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.0),
                  ),

                  if (stats.percentageChange != 0.0) ...[
                    const SizedBox(width: 12), // Spațiu între număr și procentaj
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPositiveTrend ? _accentGreen.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isPositiveTrend ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: isPositiveTrend ? _accentGreen : Colors.redAccent, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            "${stats.percentageChange.abs().toStringAsFixed(0)}%",
                            style: TextStyle(color: isPositiveTrend ? _accentGreen : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          Divider(color: Colors.white.withOpacity(0.05), height: 1),

          // --- BOTTOM: BREAKDOWN (Centrate) ---
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_soccer_rounded, color: _accentGreen, size: 12),
                        const SizedBox(width: 4),
                        Text(stats.openMatchesThisMonth.toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text("Matches", style: TextStyle(color: _textSecondary, fontSize: 10)),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(stats.tournamentsThisMonth.toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text("Tourneys", style: TextStyle(color: _textSecondary, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalMatchCard(UpcomingMatchModel match) {
    final isFull = match.currentPlayers >= match.maxPlayers;
    final double fillPercentage = match.maxPlayers > 0
        ? (match.currentPlayers / match.maxPlayers).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (_) => MatchOverviewPage(matchId: match.id)));
      },
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _bgDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_month_rounded, color: _accentGreen, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat("dd MMM • HH:mm").format(match.startsAt),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (isFull)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "FULL",
                      style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (match.location != null)
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: _textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          match.location!,
                          style: TextStyle(color: _textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Players joined", style: TextStyle(color: _textSecondary, fontSize: 11)),
                    Text(
                      "${match.currentPlayers} / ${match.maxPlayers}",
                      style: TextStyle(
                        color: isFull ? _textSecondary : _accentGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _bgDark,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fillPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isFull ? _textSecondary : _accentGreen,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: isFull ? [] : [
                          BoxShadow(color: _accentGreen.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 1))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalTournamentCard(UpcomingTournamentModel tournament) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TournamentDetailsPage(tournamentId: tournament.id)));
      },
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _bgDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat("dd MMM").format(tournament.startsAt),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tournament.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tournament.location != null && tournament.location!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: _textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tournament.location!,
                          style: TextStyle(color: _textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            Row(
              children: [
                if (tournament.teamBadgeUrl != null && tournament.teamBadgeUrl!.isNotEmpty)
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: _bgDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        "${tournament.teamBadgeUrl!}?t=${DateTime.now().millisecondsSinceEpoch}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.shield_rounded, color: _textSecondary, size: 14),
                      ),
                    ),
                  )
                else
                  Icon(
                      tournament.teamName != null && tournament.teamName!.isNotEmpty
                          ? Icons.shield_rounded
                          : Icons.person_rounded,
                      color: _textSecondary,
                      size: 20
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tournament.teamName != null && tournament.teamName!.isNotEmpty
                        ? tournament.teamName!
                        : "Registered",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.stadium_rounded, color: _accentGreen.withOpacity(0.5), size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              "No upcoming events",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "You don't have any matches or tournaments scheduled yet. Head over to the map to find a game!",
              textAlign: TextAlign.center,
              style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}