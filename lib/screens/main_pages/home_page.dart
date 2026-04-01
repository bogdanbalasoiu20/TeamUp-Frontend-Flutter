import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/models/home_model.dart';

import 'package:team_up_fe_new/models/upcoming_match.dart';
import 'package:team_up_fe_new/models/upcoming_tournament.dart';
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
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
                  const SizedBox(width: 6),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
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
          ),
        ),

        const SizedBox(width: 16),

      ],
    );
  }

  Widget _buildContent() {
    final matches = _data?.upcoming.matches ?? [];
    final tournaments = _data?.upcoming.tournaments ?? [];
    final stats = _data?.stats;

    if (matches.isEmpty && tournaments.isEmpty && stats == null) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stats != null) ...[
          _buildSectionTitle("ACTIVITY THIS MONTH"),
          const SizedBox(height: 12),
          _buildCombinedStatsCard(stats),
          const SizedBox(height: 24),
        ],

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

  Widget _buildCombinedStatsCard(dynamic stats) {
    final bool isPositiveTrend = stats.percentageChange >= 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardSurface,
            _bgDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.analytics_rounded,
                size: 130,
                color: Colors.white.withOpacity(0.02),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: _accentGreen),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TOTAL ACTIVITIES",
                            style: TextStyle(
                                color: _textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                stats.totalThisMonth.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0
                                ),
                              ),
                              if (stats.percentageChange != 0.0) ...[
                                const SizedBox(width: 12),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPositiveTrend ? _accentGreen.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPositiveTrend ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                        color: isPositiveTrend ? _accentGreen : Colors.redAccent,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${stats.percentageChange.abs().toStringAsFixed(0)}%",
                                        style: TextStyle(
                                          color: isPositiveTrend ? _accentGreen : Colors.redAccent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _accentGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.insights_rounded, color: _accentGreen, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _bgDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.sports_soccer_rounded, color: _accentGreen, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stats.openMatchesThisMonth.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.0),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Matches",
                                  style: TextStyle(color: _textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _bgDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stats.tournamentsThisMonth.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.0),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Tournaments",
                                  style: TextStyle(color: _textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildHorizontalMatchCard(UpcomingMatchModel match) {
    final isFull = match.currentPlayers >= match.maxPlayers;
    final double fillPercentage = match.maxPlayers > 0
        ? (match.currentPlayers / match.maxPlayers).clamp(0.0, 1.0)
        : 0.0;

    return Container(
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
    );
  }

  Widget _buildHorizontalTournamentCard(UpcomingTournamentModel tournament) {
    return Container(
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

          // --- DATA ---
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

          // --- TITLU SI LOCATIE ---
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

          // ---ECHIPA SI BADGE ---
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