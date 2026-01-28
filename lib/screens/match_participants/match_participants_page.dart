import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/invitable_friend.dart';
import 'package:team_up_fe_new/models/match_info.dart';
import 'package:team_up_fe_new/screens/match_participants/invited_tab_creator.dart';
import 'package:team_up_fe_new/screens/chat/match_chat_page.dart';
import 'package:team_up_fe_new/screens/matches/match_details_page.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';
import 'package:team_up_fe_new/services/match_api.dart';
import 'package:team_up_fe_new/utils/mini_action_button.dart';
import '../../models/participant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/match_participant_api.dart';
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

  List<InvitableFriend> invitableFriends = [];
  bool loadingInvitable = false;
  String inviteSearch = "";

  int invitedSubTab = 0;

  late AnimationController barController;
  late Animation<Offset> barOffset;

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

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

    _loadCurrentUser();
    _loadMatchInfo();
    _loadParticipants();
    if (isCreator()) {
      _loadInvitableFriends();
    }

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
  }

  Future<void> _loadMatchInfo() async {
    final info = await MatchApi.fetchMatchDetails(widget.matchId);

    setState(() {
      matchInfo = info;
    });
  }

  Future<void> _loadInvitableFriends({String? search}) async {
    if (!isCreator()) return;

    setState(() => loadingInvitable = true);

    final result = await MatchParticipantApi.fetchInvitableFriends(
      widget.matchId,
      search: search,
    );

    setState(() {
      invitableFriends = result;
      loadingInvitable = false;
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
    final confirmed = participants.where((p) => p.status == "ACCEPTED").toList();
    final invited = participants.where((p) => p.status == "INVITED").toList();
    final requests = participants.where((p) => p.status == "REQUESTED").toList();
    final waitlist = participants.where((p) => p.status == "WAITLIST").toList();
    final me = getCurrentParticipant();
    final bool canChat = me?.status == "ACCEPTED" || creatorId == currentUserId;

    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Transform.rotate(
              angle: -0.2,

            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Match",
                              style: TextStyle(
                                color: _accentGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Overview",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //   padding: const EdgeInsets.all(10),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white.withOpacity(0.05),
                      //     shape: BoxShape.circle,
                      //     border: Border.all(color: Colors.white.withOpacity(0.1)),
                      //   ),
                      //   child: const Icon(Icons.stadium_outlined, color: Colors.white),
                      // )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: _cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _mainTabButton("Participants", 0),
                        _mainTabButton("Details", 1),
                        _mainTabButton("Chat", 2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (mainTab == 0)
                  SlideTransition(
                    position: barOffset,
                    child: Center(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _reactionPill("Confirmed", 0),
                              const SizedBox(width: 8),
                              _reactionPill("Invited", 1),
                              const SizedBox(width: 8),
                              _reactionPill("Requests", 2),
                              const SizedBox(width: 8),
                              _reactionPill("Waitlist", 3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: loading
                      ? Center(child: CircularProgressIndicator(color: _accentGreen))
                      : _buildContent(
                      confirmed, invited, requests, waitlist, canChat),
                ),
                if (mainTab == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    child: _buildBottomActionButton(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainTabButton(String label, int index) {
    bool selected = mainTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => mainTab = index);
          if (index == 0) {
            barController.forward();
          } else {
            barController.reverse();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _accentGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _reactionPill(String text, int idx) {
    bool selected = statusTab == idx;

    return GestureDetector(
      onTap: () => setState(() => statusTab = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _cardSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _accentGreen : _textSecondary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? _accentGreen : _textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionButton() {
    if (currentUsername == null) return const SizedBox.shrink();

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

    switch (me.status) {
      case "REQUESTED":
        return _cancelRequestButton();
      case "INVITED":
        return _inviteDecisionBlock();
      case "WAITLIST":
        return _leaveWaitlistButton();
      case "ACCEPTED":
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _joinButtonVisual() {
    return ActionButtonAnimated(
      colors: [const Color(0xFF00E676), const Color(0xFF00BFA5)],
      text: "JOIN MATCH",
      onTap: () async {
        try {
          await MatchParticipantApi.joinMatch(widget.matchId);
          await _loadParticipants();
          showTopBanner(context, "Join request sent!");
        } catch (e) {
          showTopBanner(context, "Join Error", error: true);
        }
      },
    );
  }

  Widget _cancelRequestButton() {
    return ActionButtonAnimated(
      colors: const [Color(0xFFCF6679), Color(0xFFB00020)],
      text: "CANCEL REQUEST",
      onTap: () async {
        try {
          await MatchParticipantApi.cancelRequest(widget.matchId);
          await _loadParticipants();
          showTopBanner(context, "Canceled the join request");
        } catch (e) {
          showTopBanner(context, "Cancel request error", error: true);
        }
      },
    );
  }

  Widget _inviteDecisionBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "You have been invited to this match",
          style: TextStyle(
            color: _textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ActionButtonAnimated(
                colors: [const Color(0xFF00E676), const Color(0xFF00BFA5)],
                text: "ACCEPT",
                onTap: () async {
                  try {
                    await MatchParticipantApi.acceptInvite(widget.matchId);
                    await _loadParticipants();
                    showTopBanner(context, "Invite accepted");
                  } catch (e) {
                    showTopBanner(context, "Accept invite error", error: true);
                  }
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ActionButtonAnimated(
                colors: const [Color(0xFFCF6679), Color(0xFFB00020)],
                text: "DECLINE",
                onTap: () async {
                  try {
                    await MatchParticipantApi.declineInvite(widget.matchId);
                    await _loadParticipants();
                    showTopBanner(context, "Invite declined");
                  } catch (e) {
                    showTopBanner(context, "Decline invite error", error: true);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _leaveWaitlistButton() {
    return ActionButtonAnimated(
      colors: const [Color(0xFFEB5757), Color(0xFFC0392B)],
      text: "LEAVE WAITLIST",
      onTap: () async {
        try {
          await MatchParticipantApi.leaveMatch(widget.matchId);
          await _loadParticipants();
          showTopBanner(context, "Left waitlist");
        } catch (e) {
          showTopBanner(context, "Leave waitlist error", error: true);
        }
      },
    );
  }

  Widget _joinWaitlistButton() {
    return ActionButtonAnimated(
      colors: const [Color(0xFFFFAB00), Color(0xFFFF6D00)],
      text: "JOIN WAITLIST",
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

  Widget _buildContent(
      List<Participant> confirmed,
      List<Participant> invited,
      List<Participant> requests,
      List<Participant> waitlist,
      bool canChat) {
    if (mainTab == 1) {
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
    }

    if (mainTab == 2) {
      return MatchChatTab(
        matchId: widget.matchId,
        currentUserId: currentUserId ?? "",
        isAllowedToChat: canChat,
      );
    }

    List<List<Participant>> sections = [
      confirmed,
      invited,
      requests,
      waitlist,
    ];

    if (statusTab == 1) {
      if (!isCreator()) {
        return _buildUserList(invited);
      }
      return InvitedTabCreator(
        matchId: widget.matchId,
        invitedParticipants: invited,
        onInviteSent: () async {
          await _loadParticipants();
        },
      );
    }

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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_outlined, size: 48, color: _textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "No players in this section",
              style: TextStyle(
                fontSize: 16,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
    final confirmed = participants.where((p) => p.status == "ACCEPTED").toList();
    final maxPlayers = matchInfo?.maxPlayers;
    final isFull = maxPlayers != null && confirmed.length >= maxPlayers;

    final bool canPromote = creator && p.status == "WAITLIST" && !isFull;
    final bool canApproveRequest = creator && p.status == "REQUESTED" && !isFull;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfilePage(username: p.username),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
                border: Border.all(color: _accentGreen.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.person,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                p.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
              Icon(
                Icons.arrow_forward_rounded,
                color: _accentGreen.withOpacity(0.8),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _approveButton(Participant p) {
    return MiniActionButton(
      colors: const [Color(0xFF00E676), Color(0xFF00BFA5)],
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
      colors: const [Color(0xFFCF6679), Color(0xFFB00020)],
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
      colors: const [Color(0xFF2F80ED), Color(0xFF2980B9)],
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

  Widget _buildWaitlistContent(List<Participant> waitlist) {
    final confirmed = participants.where((p) => p.status == "ACCEPTED").toList();
    final maxPlayers = matchInfo?.maxPlayers;
    final isFull = maxPlayers != null && confirmed.length >= maxPlayers;
    final creator = isCreator();
    final bool showWarning = creator && isFull && waitlist.isNotEmpty;

    return Column(
      children: [
        if (showWarning)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3E2723).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Match is full. Increase max players to promote from waitlist.",
                    style: TextStyle(
                      color: Color(0xFFFFCC80),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _buildUserList(waitlist),
        ),
      ],
    );
  }

  Widget _buildRequestsContent(List<Participant> requests) {
    final confirmed = participants.where((p) => p.status == "ACCEPTED").toList();
    final maxPlayers = matchInfo?.maxPlayers;
    final isFull = maxPlayers != null && confirmed.length >= maxPlayers;
    final bool creator = isCreator();
    final bool showMoveButton = creator && isFull && requests.isNotEmpty;

    return Column(
      children: [
        if (showMoveButton) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3E2723).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: const Text(
              "The match is full. You can move remaining requests to the waitlist.",
              style: TextStyle(
                color: Color(0xFFFFCC80),
                fontSize: 13,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: ActionButtonAnimated(
              colors: const [Color(0xFFF2994A), Color(0xFFF2C94C)],
              text: "MOVE ALL TO WAITLIST",
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

  Widget _buildInvitedFriendsSection(List<Participant> invitedParticipants) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            cursorColor: _accentGreen,
            decoration: InputDecoration(
              hintText: "Search friends...",
              hintStyle: TextStyle(color: _textSecondary),
              prefixIcon: Icon(Icons.search, color: _textSecondary),
              filled: true,
              fillColor: _cardSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _accentGreen, width: 1),
              ),
            ),
            onChanged: (value) {
              inviteSearch = value;
              _loadInvitableFriends(search: value);
            },
          ),
        ),
        Expanded(
          child: loadingInvitable
              ? Center(child: CircularProgressIndicator(color: _accentGreen))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            itemCount: invitableFriends.length,
            itemBuilder: (_, i) {
              final f = invitableFriends[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text(
                        f.username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        f.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    f.invited
                        ? Text(
                      "Invited",
                      style: TextStyle(
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                        : SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentGreen,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await MatchParticipantApi.inviteUser(
                              widget.matchId, f.userId);
                          await _loadInvitableFriends(search: inviteSearch);
                          await _loadParticipants();
                          showTopBanner(context, "Invite sent to ${f.username}");
                        },
                        child: const Text(
                          "Invite",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (invitedParticipants.isNotEmpty) ...[
          Divider(color: Colors.white.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Already invited",
              style: TextStyle(
                color: _textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: _buildUserList(invitedParticipants)),
        ],
      ],
    );
  }
}