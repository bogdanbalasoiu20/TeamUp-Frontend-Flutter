import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/models/tournament.dart';
import 'package:team_up_fe_new/screens/tournament/create_tournament_page.dart';
import 'package:team_up_fe_new/screens/tournament/tournament_details_page.dart';
import 'package:team_up_fe_new/services/tournament_api.dart';
import 'package:team_up_fe_new/services/notifications_api.dart';
import 'package:team_up_fe_new/screens/notifications/notifications_page.dart';
import 'package:team_up_fe_new/widgets/left_menu_modal.dart';
import 'package:team_up_fe_new/widgets/top_bar.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  List<TournamentModel> tournaments = [];
  bool isLoading = true;
  String selectedFilter = "All";
  int unseenCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchTournaments();
    _loadUnseen();
  }

  Future<void> _fetchTournaments() async {
    setState(() => isLoading = true);

    try {
      String? status;

      if (selectedFilter == "Open") status = "OPEN";
      if (selectedFilter == "Ongoing") status = "ONGOING";
      if (selectedFilter == "Finished") status = "FINISHED";

      final page = await TournamentApi.getTournaments(
        status: status,
        page: 0,
        size: 20,
      );

      if (!mounted) return;

      setState(() {
        tournaments = page.content;
        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }
  }

  Future<void> _loadUnseen() async {
    try {
      final all = await NotificationsApi.fetchAll();
      final count = all.where((n) => !n.isSeen).length;
      if (mounted) setState(() => unseenCount = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTournamentPage()),
          );
          if (result == true) _fetchTournaments();
        },
        backgroundColor: _accentGreen,
        foregroundColor: Colors.black,
        elevation: 4,
        icon: const Icon(Icons.add_moderator),
        label: const Text(
          "HOST TOURNAMENT",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.0,
                            fontFamily: 'Roboto',
                          ),
                          children: [
                            const TextSpan(text: "Tournam"),
                            TextSpan(
                              text: "e",
                              style: TextStyle(color: _accentGreen),
                            ),
                            const TextSpan(text: "nts"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Compete and climb the ranks",
                        style: TextStyle(color: _textSecondary, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildFilterChip("All"),
                      _buildFilterChip("Open"),
                      _buildFilterChip("Ongoing"),
                      _buildFilterChip("Finished"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(color: _accentGreen))
                      : tournaments.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                    color: _accentGreen,
                    backgroundColor: _cardSurface,
                    onRefresh: _fetchTournaments,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
                      itemCount: tournaments.length,
                      itemBuilder: (context, index) {
                        return _buildProTournamentCard(tournaments[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _bgDark.withOpacity(0.9),
                    _bgDark.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: TopSheetBar(
                  unseenCount: unseenCount,
                  onNotificationsTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
                    _loadUnseen();
                  },
                  onMenuTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final user = prefs.getString("username");
                    if (user != null && mounted) showLeftMenuModal(context, user);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = label);
        _fetchTournaments();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _accentGreen : Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProTournamentCard(TournamentModel tournament) {
    final String month = DateFormat("MMM").format(tournament.startsAt).toUpperCase();
    final String day = DateFormat("dd").format(tournament.startsAt);
    final String timeRange = "${DateFormat("HH").format(tournament.startsAt)}:00";
    final bool isOpen = tournament.status.toUpperCase() == "OPEN";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TournamentDetailsPage(tournamentId: tournament.id)),
            );
          },
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        (isOpen ? _accentGreen : Colors.white).withOpacity(0.05),
                        Colors.transparent
                      ],
                      center: Alignment.topRight,
                      radius: 1.0,
                    ),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 65,
                          decoration: BoxDecoration(
                            color: _bgDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                month,
                                style: TextStyle(color: isOpen ? _accentGreen : _textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                day,
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tournament.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded, color: _textSecondary, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      tournament.venueName,
                                      style: TextStyle(color: _textSecondary, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, color: _textSecondary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Starts at $timeRange",
                                    style: TextStyle(color: _textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isOpen ? _accentGreen.withOpacity(0.15) : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isOpen ? _accentGreen.withOpacity(0.5) : Colors.transparent),
                          ),
                          child: Text(
                            tournament.status.toUpperCase(),
                            style: TextStyle(
                              color: isOpen ? _accentGreen : _textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 28,
                              child: Stack(
                                children: [
                                  _buildAvatarMock(0, Colors.blueGrey),
                                  _buildAvatarMock(16, Colors.deepPurple),
                                  _buildAvatarMock(32, Colors.orange),
                                ],
                              ),
                            ),
                            Text(
                              "+ joined",
                              style: TextStyle(color: _textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildMiniTag(Icons.sports_soccer, "5v5"),
                            const SizedBox(width: 8),
                            _buildMiniTag(Icons.emoji_events, "Prize"),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarMock(double leftPos, Color color) {
    return Positioned(
      left: leftPos,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: _cardSurface, width: 2),
        ),
        child: const Icon(Icons.shield, size: 14, color: Colors.white70),
      ),
    );
  }

  Widget _buildMiniTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: _textSecondary),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: _textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded, size: 80, color: _accentGreen.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text("No Tournaments Yet", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Be the pioneer. Start the first\ncompetition in your area!", textAlign: TextAlign.center, style: TextStyle(color: _textSecondary)),
        ],
      ),
    );
  }
}