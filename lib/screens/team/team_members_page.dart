import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/models/team.dart';
import 'package:team_up_fe_new/models/team_member.dart';
import 'package:team_up_fe_new/services/team_api.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';

class TeamDetailsPage extends StatefulWidget {
  final String teamId;

  const TeamDetailsPage({super.key, required this.teamId});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  bool isLoading = true;
  TeamModel? team;
  List<TeamMemberModel> members = [];
  String? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUser = prefs.getString("username");

      final results = await Future.wait([
        TeamApi.getTeam(widget.teamId),
        TeamApi.getMembers(widget.teamId),
      ]);

      if (!mounted) return;

      setState(() {
        team = results[0] as TeamModel;
        members = results[1] as List<TeamMemberModel>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading team details: $e", style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }
  }

  bool get isCaptain => team?.captainUsername == currentUser;
  bool get isMember => members.any((m) => m.username == currentUser);

  Future<void> _leaveTeam() async {
    try {
      final myMemberId = members.firstWhere((m) => m.username == currentUser).userId;
      await TeamApi.removePlayer(widget.teamId, myMemberId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to leave: $e"), backgroundColor: Colors.red.shade900),
      );
    }
  }

  Future<void> _removeMember(String userId) async {
    try {
      await TeamApi.removePlayer(widget.teamId, userId);
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove player: $e"), backgroundColor: Colors.red.shade900),
      );
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
                  "SQUAD",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Overview",
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
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            label: "RATING",
            value: team!.teamRating.toStringAsFixed(1),
            icon: Icons.star_rounded,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            label: "CHEMISTRY",
            value: "${team!.teamChemistry.toInt()}%",
            icon: Icons.science_rounded,
            color: Colors.cyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            label: "W-D-L",
            value: "${team!.wins}-${team!.draws}-${team!.losses}",
            icon: Icons.emoji_events_rounded,
            color: _accentGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(TeamMemberModel member) {
    final bool isUserCaptain = member.username == team!.captainUsername;
    final bool canKick = isCaptain && !isUserCaptain;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserProfilePage(username: member.username)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: const Icon(Icons.person, color: Colors.white54, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.username,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isUserCaptain ? Icons.stars_rounded : Icons.sports_soccer_rounded,
                            color: isUserCaptain ? Colors.amber : _textSecondary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUserCaptain ? "Captain" : "Player",
                            style: TextStyle(
                              color: isUserCaptain ? Colors.amber : _textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canKick)
                  IconButton(
                    icon: const Icon(Icons.person_remove_rounded, color: Colors.redAccent),
                    onPressed: () => _removeMember(member.userId),
                  ),
              ],
            ),
          ),
        ),
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

    if (team == null) {
      return Scaffold(
        backgroundColor: _bgDark,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Expanded(child: Center(child: Text("Team not found", style: TextStyle(color: Colors.white)))),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _cardSurface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: _accentGreen.withOpacity(0.5), width: 2),
                              ),
                              child: Center(
                                child: Icon(Icons.shield_rounded, color: _accentGreen, size: 40),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Created ${team!.createdAt.year}",
                                    style: TextStyle(color: _textSecondary, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        _buildStatsGrid(),

                        const SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TEAM ROSTER",
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              "${members.length} players",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            return _buildMemberTile(members[index]);
                          },
                        ),

                        const SizedBox(height: 32),

                        if (isMember && !isCaptain)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _leaveTeam,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _cardSurface,
                                foregroundColor: Colors.redAccent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                              ),
                              child: const Text("LEAVE TEAM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),

                        if (!isMember)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: const Text("Request feature coming soon!"), backgroundColor: _accentGreen),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentGreen,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text("REQUEST TO JOIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),

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
}