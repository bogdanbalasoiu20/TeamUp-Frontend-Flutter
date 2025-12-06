import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/match_info.dart';
import 'package:team_up_fe_new/screens/match_details_page.dart';
import 'package:team_up_fe_new/services/match_api.dart';
import 'package:team_up_fe_new/utils/mini_action_button.dart';
import '../models/participant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/match_participant_api.dart';
import 'package:team_up_fe_new/utils/action_button_animated.dart';
import 'package:team_up_fe_new/utils/top_banner.dart';

class MatchOverviewPage extends StatefulWidget {
  final String matchId;

  const MatchOverviewPage({super.key, required this.matchId});

  @override
  State<MatchOverviewPage> createState() => _MatchOverviewPageState();
}

class _MatchOverviewPageState extends State<MatchOverviewPage>
    with TickerProviderStateMixin {
  int mainTab = 0;
  int statusTab = 0;
  String? currentUsername;
  String? creatorId;
  String? currentUserId;
  MatchInfo? matchInfo;

  List<Participant> participants = [];
  bool loading = true;

  late AnimationController barController;
  late Animation<Offset> barOffset;

  @override
  void initState() {
    super.initState();

    barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    barOffset = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: barController,
      curve: Curves.easeOutBack,
    ));

    _loadMatchInfo();
    _loadParticipants();
    _loadCurrentUser();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mainTab == 0) barController.forward();
    });
  }

  Future<void> _loadParticipants() async {
    final resp = await MatchParticipantApi.fetchParticipants(widget.matchId);

    setState(() {
      creatorId = resp.creatorId;
      participants = resp.participants;
      loading = false;
    });
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString("username");
      currentUserId = prefs.getString("user_id");
    });

    print("### CURRENT USERNAME = $currentUsername");
    print("### CURRENT USER ID = $currentUserId");
  }

  Future<void> _loadMatchInfo() async {
    final info = await MatchApi.fetchMatchDetails(widget.matchId);
    print("### MATCH ID REQUESTED = ${widget.matchId}");
    print("### MATCH RESPONSE = $info");

    setState(() {
      matchInfo = info;
    });
  }



  Participant? getCurrentParticipant() {
    if (currentUsername == null) return null;

    try {
      return participants.firstWhere(
            (p) => p.username.toLowerCase() == currentUsername!.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  bool isCreator() {
    if (creatorId == null || currentUserId == null) return false;
    return creatorId == currentUserId;
  }


  @override
  void dispose() {
    barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confirmed =
    participants.where((p) => p.status == "ACCEPTED").toList();
    final invited = participants.where((p) => p.status == "INVITED").toList();
    final requests =
    participants.where((p) => p.status == "REQUESTED").toList();
    final waitlist =
    participants.where((p) => p.status == "WAITLIST").toList();
    final maxPlayers = matchInfo?.maxPlayers;
    final isFull = maxPlayers != null && confirmed.length >= maxPlayers;



    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF003B2F),
            Color(0xFF0A6F4A),
            Color(0xFFE6F5F0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Match Overview",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black45,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),

        body: Column(
          children: [
            // ---------------- MAIN NAVBAR ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        _mainTabButton("Participants", 0),
                        _mainTabButton("Details", 1),
                        _mainTabButton("Chat", 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // --------- SECOND NAVBAR ---------
            if (mainTab == 0)
              SlideTransition(
                position: barOffset,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 50,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _reactionPill(
                                  "Confirmed", 0, Colors.green),
                              const SizedBox(width: 10),
                              _reactionPill(
                                  "Invited", 1, Colors.orange),
                              const SizedBox(width: 10),
                              _reactionPill(
                                  "Requests", 2, Colors.blue),
                              const SizedBox(width: 10),
                              _reactionPill(
                                  "Waitlist", 3, Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // ---------------- CONTENT ----------------
            Expanded(
              child: loading
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : _buildContent(
                  confirmed, invited, requests, waitlist),
            ),

            // ---------------- ACTION BUTTON ----------------
            if (mainTab == 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 12),
                child: _buildBottomActionButton(),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- MAIN TAB BUTTONS ----------------

  Widget _mainTabButton(String label, int index) {
    bool selected = mainTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => mainTab = index);
          if (index == 0) barController.forward();
          else barController.reverse();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withOpacity(0.34)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(selected ? 1 : 0.8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SECOND NAVBAR BUTTONS ----------------

  Widget _reactionPill(String text, int idx, Color color) {
    bool selected = statusTab == idx;

    return GestureDetector(
      onTap: () => setState(() => statusTab = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
            selected ? Colors.white : Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ---------------- ACTION BUTTON SELECTOR ----------------

  Widget _buildBottomActionButton() {
    if (currentUsername == null) return SizedBox.shrink();

    final me = getCurrentParticipant();
    final confirmed = participants.where((p) => p.status == "ACCEPTED").toList();
    final maxPlayers = matchInfo?.maxPlayers;
    final isFull = maxPlayers != null && confirmed.length >= maxPlayers;


    if (isCreator()) return const SizedBox.shrink();

    if (me == null) {
      if (isFull) {
        return _joinWaitlistButton();
      } else {
        return _joinButtonVisual();
      }
    }

    // USER DEJA ÎN MECI
    switch (me.status) {
      case "REQUESTED":
        return _cancelRequestButton();
      case "INVITED":
        return _acceptInviteButton();
      case "WAITLIST":
        return _leaveWaitlistButton();
      case "ACCEPTED":
        return SizedBox.shrink();
      default:
        return SizedBox.shrink();
    }
  }



  // ---------------- BUTTON WIDGET TEMPLATES ----------------

  Widget _actionButton({required List<Color> colors, required String text}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }



  // ---------------- JOIN BUTTON ----------------

  Widget _joinButtonVisual() {
    return ActionButtonAnimated(
      colors: const [Color(0xFF0A6F4A), Color(0xFF46C264)],
      text: "Join Match",
      onTap: () async {
        try {
          await MatchParticipantApi.joinMatch(widget.matchId);
          await _loadParticipants();
          showTopBanner(context,"Join request sent!");
        } catch (e) {
          showTopBanner(context,"Join Error", error: true);
        }
      },
    );
  }





  // ---------------- CANCEL REQUEST ----------------

  Widget _cancelRequestButton() {
    return ActionButtonAnimated(
      colors: const [Color(0xFFA30000), Color(0xFFE53935)],
      text: "Cancel Request",
      onTap: () async {
        try {
          await MatchParticipantApi.cancelRequest(widget.matchId);
          await _loadParticipants();
          showTopBanner(context,"Canceled the join request");
        } catch (e) {
          showTopBanner(context,"Cancel request error", error: true);
        }
      },
    );
  }


  // ---------------- ACCEPT INVITE ----------------

  Widget _acceptInviteButton() {
    return ActionButtonAnimated(
      colors: const [Colors.blue, Colors.lightBlue],
      text: "Accept Invite",
      onTap: () async {
        try {
          await MatchParticipantApi.acceptInvite(widget.matchId);
          await _loadParticipants();
          showTopBanner(context,"Invite accepted");
        } catch (e) {
          showTopBanner(context,"Accept invite error", error: true);
        }
      },
    );
  }


  // ---------------- LEAVE WAITLIST ----------------

  Widget _leaveWaitlistButton() {
    return ActionButtonAnimated(
      colors: const [Colors.grey, Colors.black45],
      text: "Leave Waitlist",
      onTap: () async {
        try {
          await MatchParticipantApi.leaveMatch(widget.matchId);
          await _loadParticipants();
          showTopBanner(context,"Left waitlist");
        } catch (e) {
          showTopBanner(context,"Leave waitlist error", error: true);
        }
      },
    );
  }

  Widget _joinWaitlistButton() {
    return ActionButtonAnimated(
      colors: const [Colors.grey, Colors.black54],
      text: "Join Waitlist",
      onTap: () async {
        try {
          await MatchParticipantApi.joinMatch(widget.matchId);
          await _loadParticipants();
          showTopBanner(context, "Added to waitlist!");
        } catch (e) {
          showTopBanner(context, "Error joining waitlist", error: true);
        }
      },
    );
  }





  // ---------------- SECTIONS CONTENT ----------------

  Widget _buildContent(
      List<Participant> confirmed,
      List<Participant> invited,
      List<Participant> requests,
      List<Participant> waitlist) {

    if (mainTab == 1)
      return MatchDetailsTab(
        match: matchInfo,
        creatorId: creatorId!,
        currentUserId: currentUserId,
        me: getCurrentParticipant(),
        onLeaveMatch: () async {
          await MatchParticipantApi.leaveMatch(widget.matchId);
          await _loadParticipants();
          await _loadMatchInfo();
        },
        onCancelMatch: () async {},
        onInvitePlayers: () async {},
        onRefreshRequest: () async {
          await _loadMatchInfo();
          await _loadParticipants();
        },
      );



    if (mainTab == 2)
      return _chatPlaceholder();

    List<List<Participant>> sections = [
      confirmed,
      invited,
      requests,
      waitlist,
    ];

    if (statusTab == 3) {
      return _buildWaitlistContent(waitlist);
    }

    if (statusTab == 2) {
      return _buildRequestsContent(requests);
    }

    return _buildUserList(sections[statusTab]);

  }


  Widget _buildUserList(List<Participant> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          "No users here",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      itemCount: users.length,
      itemBuilder: (_, i) => _userCard(users[i]),
    );
  }

  Widget _userCard(Participant p) {
    final bool creator = isCreator();
    final bool canApproveRequest = creator && p.status == "REQUESTED";
    final confirmed = participants.where((p) => p.status == "ACCEPTED").toList();
    final maxPlayers = matchInfo?.maxPlayers;
    final isFull = maxPlayers != null && confirmed.length >= maxPlayers;
    final bool canPromote = creator && p.status == "WAITLIST" && !isFull;


    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF0A6F4A),
            child: Text(
              p.username[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.status,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          //approve/decline a join request button
          if (canApproveRequest)
            Row(
              children: [
                _approveButton(p),
                const SizedBox(width: 10),
                _rejectButton(p),
              ],
            )
          else if (canPromote)
            _promoteButton(p)
          else
            const Icon(Icons.chevron_right, color: Colors.black45)

        ],
      ),
    );
  }


  Widget _approveButton(Participant p) {
    return MiniActionButton(
      colors: const [Color(0xFF0A6F4A), Color(0xFF46C264)],
      icon: Icons.check,
      onTap: () async {
        try {
          await MatchParticipantApi.approveRequest(widget.matchId, p.userID);
          await _loadParticipants();
          showTopBanner(context, "Request approved");
        } catch (_) {
          showTopBanner(context, "Failed to approve request", error: true);
        }
      },
    );
  }



  Widget _rejectButton(Participant p) {
    return MiniActionButton(
      colors: const [Color(0xFFA30000), Color(0xFFE53935)],
      icon: Icons.close,
      onTap: () async {
        try {
          await MatchParticipantApi.rejectRequest(widget.matchId, p.userID);
          await _loadParticipants();
          showTopBanner(context, "Request declined");
        } catch (_) {
          showTopBanner(context, "Failed to decline request", error: true);
        }
      },
    );
  }

  Widget _promoteButton(Participant p) {
    return MiniActionButton(
      colors: const [Colors.blue, Colors.lightBlue],
      icon: Icons.arrow_upward,
      onTap: () async {
        try {
          await MatchParticipantApi.promoteFromWaitlist(widget.matchId, p.userID);
          await _loadParticipants();
          showTopBanner(context, "Promoted to participants!");
        } catch (e) {
          showTopBanner(context, "Promote error", error: true);
        }
      },
    );
  }



  Widget _chatPlaceholder() {
    return const Center(
      child: Text(
        "Chat coming soon...",
        style: TextStyle(fontSize: 18, color: Colors.white70),
      ),
    );
  }


  Widget _buildWaitlistContent(List<Participant> waitlist) {
    final confirmed =
    participants.where((p) => p.status == "ACCEPTED").toList();

    final maxPlayers = matchInfo?.maxPlayers;
    final isFull = maxPlayers != null && confirmed.length >= maxPlayers;

    final creator = isCreator();

    final bool showWarning = creator && isFull && waitlist.isNotEmpty;

    return Column(
      children: [
        if (showWarning)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.4)),
            ),
            child: const Text(
              "The match is full.\n"
                  "You cannot promote players from the waitlist until a spot opens.\n"
                  "You may edit the match to increase the maximum number of players.",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),

        Expanded(
          child: _buildUserList(waitlist),
        ),
      ],
    );
  }


  Widget _buildRequestsContent(List<Participant> requests) {
    final confirmed =
    participants.where((p) => p.status == "ACCEPTED").toList();
    final maxPlayers = matchInfo?.maxPlayers;
    final isFull = maxPlayers != null && confirmed.length >= maxPlayers;

    final bool creator = isCreator();
    final bool showMoveButton = creator && isFull && requests.isNotEmpty;

    return Column(
      children: [
        if (showMoveButton) ...[
          // --- Minimal Info Text ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "The match is full. You can move remaining requests to the waitlist.",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // --- Action Button ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: ActionButtonAnimated(
              colors: const [Colors.orange, Colors.deepOrangeAccent],
              text: "Move all to waitlist",
              onTap: () async {
                try {
                  await MatchParticipantApi.moveAllRequestsToWaitlist(widget.matchId);
                  await _loadParticipants();
                  showTopBanner(context, "All requests moved to waitlist!");
                } catch (e) {
                  showTopBanner(context, "Move failed", error: true);
                }
              },
            ),
          ),
        ],

        Expanded(
          child: _buildUserList(requests),
        ),
      ],
    );
  }



}
