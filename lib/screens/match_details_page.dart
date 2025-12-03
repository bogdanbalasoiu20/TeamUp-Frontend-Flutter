import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/participant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/match_participant_api.dart';

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

    _loadParticipants();
    _loadCurrentUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mainTab == 0) barController.forward();
    });
  }

  Future<void> _loadParticipants() async {
    final res = await MatchParticipantApi.fetchParticipants(widget.matchId);
    setState(() {
      participants = res;
      loading = false;
    });
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString("username");
    setState(() {});
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

    if (me == null) return _joinButtonVisual();

    switch (me.status) {
      case "REQUESTED":
        return _cancelRequestButton();
      case "INVITED":
        return _acceptInviteButton();
      case "WAITLIST":
        return _leaveWaitlistButton();
      case "ACCEPTED":
        return _leaveButtonVisual();
      default:
        return _joinButtonVisual();
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

  void showTopBanner(String msg, {bool error = false}) {
    OverlayEntry entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 40,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: error ? Colors.red.shade700 : Colors.green.shade700,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            child: Text(
              msg,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);

    Future.delayed(const Duration(seconds: 2)).then((_) {
      entry.remove();
    });
  }


  // ---------------- JOIN BUTTON ----------------

  Widget _joinButtonVisual() {
    return GestureDetector(
      onTap: () async {
        try {
          await MatchParticipantApi.joinMatch(widget.matchId);
          await _loadParticipants();
          setState(() {});

          showTopBanner("Sent a join request!");
        } catch (e) {
          showTopBanner("Join error", error: true);
        }
      },
      child: _actionButton(
        colors: const [Color(0xFF0A6F4A), Color(0xFF46C264)],
        text: "Join Match",
      ),
    );
  }


  // ---------------- LEAVE BUTTON ----------------

  Widget _leaveButtonVisual() {
    return GestureDetector(
      onTap: () async {
        try {
          await MatchParticipantApi.leaveMatch(widget.matchId);
          await _loadParticipants();
          setState(() {});

          showTopBanner("Left the match");
        } catch (e) {
          showTopBanner("Leave match error", error: true);
        }
      },
      child: _actionButton(
        colors: [Color(0xFFA30000), Color(0xFFE53935)],
        text: "Leave Match",
      ),
    );
  }

  // ---------------- CANCEL REQUEST ----------------

  Widget _cancelRequestButton() {
    return GestureDetector(
      onTap: () async {
        try{
        await MatchParticipantApi.cancelRequest(widget.matchId);
        await _loadParticipants();
        setState(() {});

        showTopBanner("Canceled the join request");
      }catch (e) {
          showTopBanner("Cancel join request error", error: true);
        }
      },
      child: _actionButton(
        colors: [Color(0xFFA30000), Color(0xFFE53935)],
        text: "Cancel Request",
      ),
    );
  }

  // ---------------- ACCEPT INVITE ----------------

  Widget _acceptInviteButton() {
    return GestureDetector(
      onTap: () async {
        try{
        await MatchParticipantApi.acceptInvite(widget.matchId);
        await _loadParticipants();
        setState(() {});

        showTopBanner("Invite accepted");
      }catch (e) {
          showTopBanner("Accept invite error", error: true);
        }
      },
      child: _actionButton(
        colors: [Colors.blue, Colors.lightBlue],
        text: "Accept Invite",
      ),
    );
  }

  // ---------------- LEAVE WAITLIST ----------------

  Widget _leaveWaitlistButton() {
    return GestureDetector(
      onTap: () async {
        try{
        await MatchParticipantApi.leaveWaitlist(widget.matchId);
        await _loadParticipants();
        setState(() {});

        showTopBanner("Left waitlist");
      }catch (e) {
    showTopBanner("Leave waitlist error", error: true);
    }
      },
      child: _actionButton(
        colors: [Colors.grey, Colors.black45],
        text: "Leave Waitlist",
      ),
    );
  }

  // ---------------- SECTIONS CONTENT ----------------

  Widget _buildContent(
      List<Participant> confirmed,
      List<Participant> invited,
      List<Participant> requests,
      List<Participant> waitlist) {
    if (mainTab == 1) return _detailsPlaceholder();
    if (mainTab == 2) return _chatPlaceholder();

    List<List<Participant>> sections = [
      confirmed,
      invited,
      requests,
      waitlist,
    ];

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

          const Icon(Icons.chevron_right, color: Colors.black45),
        ],
      ),
    );
  }

  Widget _detailsPlaceholder() {
    return const Center(
      child: Text(
        "Match details coming soon...",
        style: TextStyle(fontSize: 18, color: Colors.white70),
      ),
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
}
