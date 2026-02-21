import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/models/team.dart';
import 'package:team_up_fe_new/screens/team/team_members_page.dart';
import 'package:team_up_fe_new/services/team_api.dart';
import 'package:team_up_fe_new/screens/notifications/notifications_page.dart';
import 'package:team_up_fe_new/services/notifications_api.dart';
import 'package:team_up_fe_new/widgets/left_menu_modal.dart';
import 'package:team_up_fe_new/widgets/top_bar.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  int unseenCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnseen();
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
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
                          const TextSpan(text: "T"),
                          TextSpan(
                            text: "e",
                            style: TextStyle(color: _accentGreen),
                          ),
                          const TextSpan(text: "ams"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Manage or discover squads",
                      style: TextStyle(color: _textSecondary, fontSize: 15),
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
                  Tab(text: "MY TEAMS"),
                  Tab(text: "EXPLORE"),
                ],
              ),

              const Expanded(
                child: TabBarView(
                  children: [
                    _MyTeamsTab(),
                    _ExploreTeamsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyTeamsTab extends StatefulWidget {
  const _MyTeamsTab();

  @override
  State<_MyTeamsTab> createState() => _MyTeamsTabState();
}

class _MyTeamsTabState extends State<_MyTeamsTab> {
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  List<TeamModel> myTeams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyTeams();
  }

  Future<void> _fetchMyTeams() async {
    setState(() => isLoading = true);
    try {
      final teams = await TeamApi.getMyTeams();
      if (mounted) {
        setState(() {
          myTeams = teams;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _showCreateTeamDialog() async {
    final TextEditingController nameController = TextEditingController();
    bool isCreating = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF091210),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: _accentGreen.withOpacity(0.3)),
              ),
              title: const Text("Create New Team", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Team Name",
                  hintStyle: TextStyle(color: _textSecondary),
                  filled: true,
                  fillColor: _cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("CANCEL", style: TextStyle(color: _textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentGreen,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: isCreating
                      ? null
                      : () async {
                    if (nameController.text.trim().isEmpty) return;

                    print("CREATE pressed with name: ${nameController.text.trim()}");

                    setDialogState(() => isCreating = true);

                    try {
                      final team = await TeamApi.createTeam(nameController.text.trim());
                      print("TEAM CREATED SUCCESSFULLY: ${team.id}");

                      if (context.mounted) {
                        Navigator.pop(context);
                        _fetchMyTeams();
                      }
                    } catch (e, stack) {
                      print("CREATE TEAM ERROR:");
                      print(e);
                      print(stack);

                      setDialogState(() => isCreating = false);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: isCreating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text("CREATE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTeamDialog,
        backgroundColor: _accentGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_moderator),
        label: const Text("CREATE TEAM", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: _accentGreen))
          : myTeams.isEmpty
          ? Center(
        child: Text(
          "You are not in any team yet.\nCreate one or explore!",
          textAlign: TextAlign.center,
          style: TextStyle(color: _textSecondary, fontSize: 16),
        ),
      )
          : RefreshIndicator(
        color: _accentGreen,
        backgroundColor: _cardSurface,
        onRefresh: _fetchMyTeams,
        child: ListView.builder(
          padding: const EdgeInsets.all(16).copyWith(bottom: 100),
          itemCount: myTeams.length,
          itemBuilder: (context, index) {
            return TeamCardWidget(team: myTeams[index]);
          },
        ),
      ),
    );
  }
}

class _ExploreTeamsTab extends StatefulWidget {
  const _ExploreTeamsTab();

  @override
  State<_ExploreTeamsTab> createState() => _ExploreTeamsTabState();
}

class _ExploreTeamsTabState extends State<_ExploreTeamsTab> {
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<TeamModel> exploredTeams = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchExploreTeams(refresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        _fetchExploreTeams();
      }
    });
  }

  Future<void> _fetchExploreTeams({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      setState(() {
        currentPage = 0;
        exploredTeams.clear();
        hasMore = true;
      });
    }

    setState(() => isLoading = true);

    try {
      final pageData = await TeamApi.exploreTeams(
        page: currentPage,
        size: 10,
        search: _searchController.text.trim(),
      );

      if (mounted) {
        setState(() {
          exploredTeams.addAll(pageData.content);
          currentPage++;
          hasMore = currentPage < pageData.totalPages;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => _fetchExploreTeams(refresh: true),
            decoration: InputDecoration(
              hintText: "Search teams...",
              hintStyle: TextStyle(color: _textSecondary.withOpacity(0.7)),
              prefixIcon: Icon(Icons.search, color: _accentGreen),
              filled: true,
              fillColor: _cardSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _accentGreen),
              ),
            ),
          ),
        ),

        Expanded(
          child: exploredTeams.isEmpty && isLoading
              ? Center(child: CircularProgressIndicator(color: _accentGreen))
              : exploredTeams.isEmpty
              ? Center(child: Text("No teams found.", style: TextStyle(color: _textSecondary)))
              : RefreshIndicator(
            color: _accentGreen,
            backgroundColor: _cardSurface,
            onRefresh: () => _fetchExploreTeams(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: exploredTeams.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == exploredTeams.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: _accentGreen),
                    ),
                  );
                }
                return TeamCardWidget(team: exploredTeams[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class TeamCardWidget extends StatelessWidget {
  final TeamModel team;
  const TeamCardWidget({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final Color cardSurface = const Color(0xFF13241E);
    final Color accentGreen = const Color(0xFF00E676);
    final Color textSecondary = const Color(0xFF8A9E96);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeamDetailsPage(teamId: team.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        team.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.shield, color: accentGreen, size: 24),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Captain: @${team.captainUsername}",
                  style: TextStyle(color: textSecondary, fontSize: 14),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10, height: 1),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn("Rating", team.teamRating.toStringAsFixed(1), Icons.star, Colors.amber),
                    _buildStatColumn("Chem", "${team.teamChemistry.toInt()}%", Icons.science, Colors.cyan),
                    _buildStatColumn("W-D-L", "${team.wins}-${team.draws}-${team.losses}", Icons.emoji_events, accentGreen),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A9E96), fontSize: 12),
        ),
      ],
    );
  }
}