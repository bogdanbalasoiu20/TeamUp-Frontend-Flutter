import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/models/home_upcoming.dart';

import 'package:team_up_fe_new/screens/matches/finish_match_screen.dart';
import 'package:team_up_fe_new/services/match_api.dart';

import 'package:team_up_fe_new/models/upcoming_match.dart';
import 'package:team_up_fe_new/models/upcoming_tournament.dart';
import 'package:team_up_fe_new/services/home_api.dart';

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
  HomeUpcomingModel? _data;
  String _username = "Player";

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


  // Verificare meci nefinalizat

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

      debugPrint("AUTO FINISH MATCH:");
      debugPrint("id=${match.id}");
      debugPrint("creator=${match.creatorId}");
      debugPrint("status=${match.status}");

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

  // incarcare date Dashboard
  Future<void> _loadUserAndData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString("username");
      if (savedUser != null) {
        _username = savedUser;
      }

      final data = await HomeApi.getUpcoming();

      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
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


  // UI: Construire Pagina

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          color: _accentGreen,
          backgroundColor: _cardSurface,
          onRefresh: _loadUserAndData,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: _accentGreen))
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back,",
              style: TextStyle(color: _textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _cardSurface,
            shape: BoxShape.circle,
            border: Border.all(color: _accentGreen.withOpacity(0.5), width: 2),
          ),
          child: Icon(Icons.person_rounded, color: _accentGreen, size: 24),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final matches = _data?.matches ?? [];
    final tournaments = _data?.tournaments ?? [];

    if (matches.isEmpty && tournaments.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. NEXT MATCH (Compact Hero)
        if (matches.isNotEmpty) ...[
          _buildSectionTitle("NEXT MATCH"),
          const SizedBox(height: 12),
          _buildCompactHeroMatchCard(matches.first),
          const SizedBox(height: 24),
        ],

        // 2. STATISTICI (Placeholder)
        _buildSectionTitle("THIS MONTH"),
        const SizedBox(height: 12),
        _buildStatsRow(),
        const SizedBox(height: 24),

        // 3. UPCOMING MATCHES (Scroll Orizontal)
        if (matches.length > 1) ...[
          _buildSectionTitle("UPCOMING MATCHES"),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: matches.length - 1,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildHorizontalMatchCard(matches[index + 1]);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 4. UPCOMING TOURNAMENTS (Scroll Orizontal)
        if (tournaments.isNotEmpty) ...[
          _buildSectionTitle("UPCOMING TOURNAMENTS"),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
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

  Widget _buildCompactHeroMatchCard(UpcomingMatchModel match) {
    final formattedDate = DateFormat("EEE, dd MMM • HH:mm").format(match.startsAt);
    final isFull = match.currentPlayers >= match.maxPlayers;
    final double fillPercentage = match.maxPlayers > 0 ? (match.currentPlayers / match.maxPlayers).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentGreen.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: _accentGreen.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: _accentGreen, size: 14),
                  const SizedBox(width: 6),
                  Text(formattedDate, style: TextStyle(color: _accentGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              if (isFull)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: const Text("FULL", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            match.title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (match.location != null)
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: _textSecondary, size: 14),
                const SizedBox(width: 4),
                Expanded(child: Text(match.location!, style: TextStyle(color: _textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Players: ${match.currentPlayers}/${match.maxPlayers}", style: TextStyle(color: isFull ? Colors.white : _accentGreen, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(color: _bgDark, borderRadius: BorderRadius.circular(3)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fillPercentage,
              child: Container(decoration: BoxDecoration(color: isFull ? _textSecondary : _accentGreen, borderRadius: BorderRadius.circular(3))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("Matches Played", "12", Icons.sports_soccer_rounded)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("Goals / Assists", "8", Icons.bolt_rounded)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                icon,
                size: 80,
                color: Colors.white.withOpacity(0.02),
              ),
            ),

            // --- CONTENT ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: _accentGreen, size: 22),
                  const SizedBox(height: 12),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(label, style: TextStyle(color: _textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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

    return Container(
      width: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardSurface,
            _bgDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.sports_soccer_rounded,
                size: 110,
                color: Colors.white.withOpacity(0.03),
              ),
            ),

            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: _accentGreen),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 16, top: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _accentGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.sports_soccer_rounded, color: _accentGreen, size: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFull ? Colors.transparent : _accentGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isFull ? _textSecondary.withOpacity(0.3) : _accentGreen.withOpacity(0.3)),
                        ),
                        child: Text(
                          "${match.currentPlayers}/${match.maxPlayers}",
                          style: TextStyle(color: isFull ? _textSecondary : _accentGreen, fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                      match.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_filled_rounded, color: _textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(DateFormat("dd MMM, HH:mm").format(match.startsAt), style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
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

  Widget _buildHorizontalTournamentCard(UpcomingTournamentModel tournament) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardSurface,
            _bgDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.amber.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.emoji_events_rounded,
                size: 110,
                color: Colors.amber.withOpacity(0.03),
              ),
            ),

            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: Colors.amber),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 16, top: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 16),
                      ),
                      if (tournament.teamName != null && tournament.teamName!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text(tournament.teamName!, style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                      tournament.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.event_available_rounded, color: _textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text("Starts ${DateFormat("dd MMM").format(tournament.startsAt)}", style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
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