import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/models/team.dart';
import 'package:team_up_fe_new/screens/team/team_members_page.dart';
import 'package:team_up_fe_new/services/team_api.dart';
import 'package:team_up_fe_new/screens/notifications/notifications_page.dart';
import 'package:team_up_fe_new/services/notifications_api.dart';
import 'package:team_up_fe_new/utils/compress_image.dart';
import 'package:team_up_fe_new/widgets/left_menu_modal.dart';
import 'package:team_up_fe_new/widgets/top_bar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:team_up_fe_new/utils/image_picker.dart';
import 'package:team_up_fe_new/widgets/team_badge_picker.dart';

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
    XFile? pickedImage;
    bool isCreating = false;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8), // Fundal mai întunecat pentru contrast
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF091210), // _bgDark
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _accentGreen.withOpacity(0.2), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _accentGreen.withOpacity(0.05),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Build Your Squad",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: isCreating ? null : () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded, color: _textSecondary, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- BADGE PICKER ---
                    TeamBadgePicker(
                      badgeUrl: pickedImage?.path,
                      onPick: isCreating
                          ? () {}
                          : () async {
                        final image = await ImagePickerUtil.pickFromGallery();
                        if (image != null) {
                          setDialogState(() {
                            pickedImage = image;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Tap to upload team logo",
                      style: TextStyle(
                        color: _textSecondary.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- TEAM NAME INPUT ---
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      enabled: !isCreating,
                      decoration: InputDecoration(
                        labelText: "Team Name",
                        labelStyle: TextStyle(color: _textSecondary),
                        floatingLabelStyle: TextStyle(color: _accentGreen),
                        filled: true,
                        fillColor: _cardSurface,
                        //refixIcon: Icon(Icons.shield_outlined, color: _accentGreen.withOpacity(0.8), size: 22),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: _accentGreen, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- CREATE BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentGreen,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          disabledBackgroundColor: _cardSurface,
                        ),
                        onPressed: isCreating
                            ? null
                            : () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Team name is required", style: TextStyle(color: Colors.white)),
                                backgroundColor: Colors.red.shade900,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isCreating = true);

                          try {
                            final team = await TeamApi.createTeam(nameController.text.trim());

                            if (pickedImage != null) {
                              final prefs = await SharedPreferences.getInstance();
                              final token = prefs.getString("access_token");

                              if (token != null) {
                                print("COMPRIMĂM BADGE-UL...");
                                final file = File(pickedImage!.path);
                                final compressedFile = await compressImage(file);

                                if (compressedFile != null) {
                                  final fileSize = await compressedFile.length();

                                  if (fileSize > 5 * 1024 * 1024) {
                                    throw Exception("Image too large after compression (max 5MB).");
                                  }

                                  print("UPLOADING BADGE...");
                                  await TeamApi.uploadTeamBadge(
                                    teamId: team.id,
                                    filePath: compressedFile.path,
                                    token: token,
                                  );
                                } else {
                                  print("Eroare la compresie, sărim peste upload.");
                                }
                              } else {
                                print("No token found, skipping badge upload");
                              }
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                              _fetchMyTeams();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Squad created successfully!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  backgroundColor: _accentGreen,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isCreating = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: $e", style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.red.shade900,
                                ),
                              );
                            }
                          }
                        },
                        child: isCreating
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                        )
                            : const Text(
                          "CREATE SQUAD",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
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
        heroTag: null,
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
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentGreen.withOpacity(0.3), width: 1.5),
                      ),
                      child: team.badgeUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "${team.badgeUrl!}?t=${DateTime.now().millisecondsSinceEpoch}",
                          fit: BoxFit.cover,
                        ),
                      )
                          : Icon(Icons.shield_rounded, color: accentGreen, size: 32),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Captain: @${team.captainUsername}",
                            style: TextStyle(color: textSecondary, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.white10, height: 1),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn("RATING", team.overallRating.toString(), Icons.star_rounded, Colors.amber),

                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),

                    _buildStatColumn("CHEMISTRY", "${team.teamChemistry.toInt()}%", Icons.science_rounded, Colors.cyan),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A9E96), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ],
    );
  }
}