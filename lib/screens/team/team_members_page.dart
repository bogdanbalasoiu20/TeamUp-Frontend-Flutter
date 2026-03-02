import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/models/team.dart';
import 'package:team_up_fe_new/models/team_full_profile.dart';
import 'package:team_up_fe_new/models/team_member.dart';
import 'package:team_up_fe_new/models/team_statistics.dart';
import 'package:team_up_fe_new/screens/chat/team_chat_tab.dart';
import 'package:team_up_fe_new/screens/team/team_statistics_page.dart';
import 'package:team_up_fe_new/services/team_api.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';
import '../../models/user_search_result.dart';
import '../../services/friend_api.dart';

class PitchPosition {
  final int slotIndex;
  final String label;
  final Alignment alignment;

  PitchPosition({
    required this.slotIndex,
    required this.label,
    required this.alignment,
  });
}

class TeamDetailsPage extends StatefulWidget {
  final String teamId;

  const TeamDetailsPage({super.key, required this.teamId});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> with SingleTickerProviderStateMixin {
  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  bool isLoading = true;
  TeamModel? team;
  List<TeamMemberModel> members = [];
  TeamStatisticsModel? teamStats;
  String? currentUser;

  late TabController _tabController;

  final List<PitchPosition> _pitchPositions = [
    // --- ATACANȚI ---
    PitchPosition(slotIndex: 12, label: 'LW', alignment: const Alignment(-0.8, -0.85)),
    PitchPosition(slotIndex: 13, label: 'ST', alignment: const Alignment(-0.25, -0.95)),
    PitchPosition(slotIndex: 14, label: 'ST', alignment: const Alignment(0.25, -0.95)),
    PitchPosition(slotIndex: 15, label: 'RW', alignment: const Alignment(0.8, -0.85)),

    // --- MIJLOCAȘI ---
    PitchPosition(slotIndex: 6, label: 'LM', alignment: const Alignment(-0.90, -0.30)),
    PitchPosition(slotIndex: 7, label: 'CM', alignment: const Alignment(-0.40, -0.10)),
    PitchPosition(slotIndex: 8, label: 'CDM', alignment: const Alignment(0.0, 0.1)),
    PitchPosition(slotIndex: 9, label: 'CAM', alignment: const Alignment(0.0, -0.5)),
    PitchPosition(slotIndex: 10, label: 'CM', alignment: const Alignment(0.40, -0.10)),
    PitchPosition(slotIndex: 11, label: 'RM', alignment: const Alignment(0.90, -0.30)),

    // --- FUNDAȘI ---
    PitchPosition(slotIndex: 1, label: 'LB', alignment: const Alignment(-0.90, 0.40)),
    PitchPosition(slotIndex: 2, label: 'CB', alignment: const Alignment(-0.45, 0.50)),
    PitchPosition(slotIndex: 3, label: 'CB', alignment: const Alignment(0.0, 0.55)),
    PitchPosition(slotIndex: 4, label: 'CB', alignment: const Alignment(0.45, 0.50)),
    PitchPosition(slotIndex: 5, label: 'RB', alignment: const Alignment(0.90, 0.40)),

    // --- PORTAR ---
    PitchPosition(slotIndex: 0, label: 'GK', alignment: const Alignment(0.0, 1.0)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUser = prefs.getString("username");

      final results = await Future.wait([
        TeamApi.getTeamProfile(widget.teamId),
        TeamApi.getMembers(widget.teamId),
      ]);

      if (!mounted) return;

      final profile = results[0] as TeamFullProfileModel;

      setState(() {
        team = profile.team;
        teamStats = profile.statistics;
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

  String _getCurrentUserId() {
    try {
      return members.firstWhere((m) => m.username == currentUser).userId;
    } catch (e) {
      return "";
    }
  }

  List<TeamMemberModel> get pitchPlayers =>
      members.where((m) => m.squadType == SquadType.PITCH).toList()
        ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));

  List<TeamMemberModel> get benchPlayers =>
      members.where((m) => m.squadType == SquadType.BENCH).toList()
        ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));

  Future<void> _handleSwap(TeamMemberModel movingPlayer, SquadType targetType, int? targetIndex) async {
    if (!isCaptain) return;
    HapticFeedback.lightImpact();

    final oldType = movingPlayer.squadType;
    final oldIndex = movingPlayer.slotIndex;

    if (targetType == SquadType.BENCH && targetIndex == null) {
      targetIndex = benchPlayers.isEmpty
          ? 0
          : benchPlayers.map((e) => e.slotIndex).reduce((a, b) => a > b ? a : b) + 1;
    }

    if (oldType == targetType && oldIndex == targetIndex) return;

    TeamMemberModel? existingPlayer;
    if (targetType == SquadType.PITCH) {
      try {
        existingPlayer = pitchPlayers.firstWhere((p) => p.slotIndex == targetIndex);
      } catch (_) {}
    }

    setState(() {
      members.removeWhere((m) => m.userId == movingPlayer.userId);
      members.add(_cloneMember(movingPlayer, targetType, targetIndex!));

      if (existingPlayer != null) {
        members.removeWhere((m) => m.userId == existingPlayer!.userId);
        members.add(_cloneMember(existingPlayer, oldType, oldIndex));
      }
    });

    try {
      await TeamApi.updatePosition(
        teamId: widget.teamId,
        userId: movingPlayer.userId,
        squadType: targetType.name,
        slotIndex: targetIndex!,
      );

      if (existingPlayer != null) {
        await TeamApi.updatePosition(
          teamId: widget.teamId,
          userId: existingPlayer.userId,
          squadType: oldType.name,
          slotIndex: oldIndex,
        );
      }
    } catch (e) {
      _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save position: $e"), backgroundColor: Colors.red.shade900),
        );
      }
    }
  }

  TeamMemberModel _cloneMember(TeamMemberModel m, SquadType newType, int newIndex) {
    return TeamMemberModel(
      userId: m.userId,
      username: m.username,
      role: m.role,
      joinedAt: m.joinedAt,
      squadType: newType,
      slotIndex: newIndex,
    );
  }

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

  void _showPlayerOptions(TeamMemberModel member) {
    final bool isUserCaptain = member.username == team!.captainUsername;
    final bool canKick = isCaptain && !isUserCaptain;

    showModalBottomSheet(
      context: context,
      backgroundColor: _bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _cardSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person_outline_rounded, color: _accentGreen),
                ),
                title: const Text(
                  "View Profile",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserProfilePage(username: member.username)),
                  );
                },
              ),
              if (canKick)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_remove_rounded, color: Colors.redAccent),
                  ),
                  title: const Text(
                    "Remove from Team",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeMember(member.userId);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
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
            value: team!.rating.overall.toString(),
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
            value: "${teamStats?.wins ?? 0}-${teamStats?.draws ?? 0}-${teamStats?.losses ?? 0}",
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

  Widget _buildPlayerMarker(TeamMemberModel member, {String? positionLabel}) {
    final bool isUserCaptain = member.username == team!.captainUsername;

    return GestureDetector(
      onTap: () => _showPlayerOptions(member),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _cardSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: isUserCaptain ? Colors.amber : _accentGreen, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              if (isUserCaptain)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              member.username,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (positionLabel != null) ...[
            const SizedBox(height: 2),
            Text(
              positionLabel,
              style: TextStyle(
                color: _accentGreen,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildEmptySlot(bool isHovered, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isHovered ? _accentGreen.withOpacity(0.3) : Colors.white.withOpacity(0.08),
            border: Border.all(
              color: isHovered ? _accentGreen : Colors.white.withOpacity(0.2),
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Icon(
            Icons.add,
            color: isHovered ? Colors.white : Colors.white.withOpacity(0.3),
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggablePlayer(TeamMemberModel member, {String? positionLabel}) {
    Widget playerWidget = _buildPlayerMarker(member, positionLabel: positionLabel);

    if (!isCaptain) return playerWidget;

    return Draggable<TeamMemberModel>(
      data: member,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: playerWidget,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: playerWidget,
      ),
      child: playerWidget,
    );
  }

  Widget _buildPitch() {
    final Color pitchGreen = const Color(0xFF163324);
    final Color lineOpacity = Colors.white.withOpacity(0.15);

    return Container(
      width: double.infinity,
      height: 520,
      decoration: BoxDecoration(
        color: pitchGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lineOpacity, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 2,
              color: lineOpacity,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: lineOpacity, width: 2),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 140,
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: lineOpacity, width: 2),
                  right: BorderSide(color: lineOpacity, width: 2),
                  bottom: BorderSide(color: lineOpacity, width: 2),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 140,
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: lineOpacity, width: 2),
                  right: BorderSide(color: lineOpacity, width: 2),
                  top: BorderSide(color: lineOpacity, width: 2),
                ),
              ),
            ),
          ),

          ..._pitchPositions.map((pitchPos) {
            TeamMemberModel? assignedPlayer;
            try {
              assignedPlayer = pitchPlayers.firstWhere((p) => p.slotIndex == pitchPos.slotIndex);
            } catch (_) {}

            return Align(
              alignment: pitchPos.alignment,
              child: isCaptain
                  ? DragTarget<TeamMemberModel>(
                onWillAccept: (data) => true,
                onAccept: (member) => _handleSwap(member, SquadType.PITCH, pitchPos.slotIndex),
                builder: (context, candidateData, rejectedData) {
                  final isHovered = candidateData.isNotEmpty;

                  return Container(
                    width: 60,
                    height: 95,
                    alignment: Alignment.center,
                    child: assignedPlayer != null
                        ? _buildDraggablePlayer(assignedPlayer, positionLabel: pitchPos.label)
                        : _buildEmptySlot(isHovered, pitchPos.label),
                  );
                },
              )
                  : (assignedPlayer != null
                  ? SizedBox(
                  width: 60,
                  height: 95,
                  child: Center(child: _buildPlayerMarker(assignedPlayer, positionLabel: pitchPos.label)))
                  : const SizedBox.shrink()),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSubstitutions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "SUBSTITUTIONS",
              style: TextStyle(
                color: _textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              "${benchPlayers.length} reserves",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        DragTarget<TeamMemberModel>(
          onWillAccept: (data) => true,
          onAccept: (member) => _handleSwap(member, SquadType.BENCH, null),
          builder: (context, candidateData, rejectedData) {
            final isHovered = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isHovered ? _accentGreen.withOpacity(0.1) : _cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHovered ? _accentGreen : Colors.white.withOpacity(0.05),
                ),
              ),
              child: benchPlayers.isEmpty
                  ? Center(
                child: Text(
                  isHovered ? "Drop player here" : "No players on the bench.",
                  style: TextStyle(
                      color: isHovered ? _accentGreen : _textSecondary, fontStyle: FontStyle.italic),
                ),
              )
                  : Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: benchPlayers.map((member) => _buildDraggablePlayer(member)).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSquadTab() {
    return SingleChildScrollView(
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

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamStatisticsPage(teamId: widget.teamId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_rounded, color: _accentGreen, size: 20),
                  const SizedBox(width: 8),
                  const Text("VIEW FULL STATISTICS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TACTICAL VIEW",
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${pitchPlayers.length} on pitch",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (isCaptain)
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => _AddPlayerModal(
                        teamId: widget.teamId,
                        currentMembers: members,
                        onAdded: () {
                          _fetchData();
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _accentGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, color: _accentGreen, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "ADD",
                          style: TextStyle(
                            color: _accentGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          _buildPitch(),

          _buildSubstitutions(),

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

                // AM ADAUGAT TAB BAR-UL
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: _accentGreen,
                    indicatorWeight: 3,
                    labelColor: _accentGreen,
                    unselectedLabelColor: _textSecondary,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: "SQUAD"),
                      Tab(text: "CHAT"),
                    ],
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: SQUAD
                      _buildSquadTab(),

                      // TAB 2: CHAT
                      TeamChatTab(
                        teamId: widget.teamId,
                        currentUserId: _getCurrentUserId(),
                        isAllowedToChat: isMember,
                      ),
                    ],
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

class _AddPlayerModal extends StatefulWidget {
  final String teamId;
  final List<TeamMemberModel> currentMembers;
  final VoidCallback onAdded;

  const _AddPlayerModal({
    required this.teamId,
    required this.currentMembers,
    required this.onAdded,
  });

  @override
  State<_AddPlayerModal> createState() => _AddPlayerModalState();
}

class _AddPlayerModalState extends State<_AddPlayerModal> {
  final TextEditingController _searchController = TextEditingController();
  List<UserSearchResult> results = [];
  bool loading = false;

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);

  Future<void> _search(String q) async {
    q = q.trim();

    if (q.isEmpty) {
      if (mounted) {
        setState(() {
          results = [];
          loading = false;
        });
      }
      return;
    }

    setState(() => loading = true);

    try {
      final r = await FriendApi.searchUsers(q);
      if (mounted) {
        setState(() {
          results = r.where((u) => !widget.currentMembers.any((m) => m.userId == u.id)).toList();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _addPlayer(String userId) async {
    try {
      await TeamApi.addPlayer(widget.teamId, userId);
      if (mounted) {
        widget.onAdded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Player added to team!", style: TextStyle(color: Colors.black)), backgroundColor: _accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add player: $e"), backgroundColor: Colors.red.shade900),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
            "Add Player",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _search(value),
              cursorColor: _accentGreen,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "Search username...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search, color: _accentGreen),
                filled: true,
                fillColor: _cardSurface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                  borderSide: BorderSide(color: _accentGreen),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    _search("");
                  },
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: CircularProgressIndicator(color: _accentGreen),
            ),
          if (!loading && results.isEmpty && _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text("No users found", style: TextStyle(color: Colors.white.withOpacity(0.5))),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemBuilder: (context, i) {
                final u = results[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          backgroundImage: u.photoUrl.isNotEmpty ? NetworkImage(u.photoUrl) : null,
                          child: u.photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.white54) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            u.username,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _addPlayer(u.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _accentGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Add",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
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