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
  int mainTab = 0;   // 0 = Participants
  int statusTab = 0; // 0 = Confirmed
  String? currentUsername;

  List<Participant> participants = [];
  bool loading = true;

  // --- Animation for second navbar ---
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

    // Safely start animation after first frame
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
    setState(() {
      currentUsername = prefs.getString("username");
    });
    print("### CURRENT USERNAME = $currentUsername");
  }

  bool isUserParticipant() {
    if (currentUsername == null) return false;

    return participants.any(
          (p) => p.username.toLowerCase() == currentUsername!.toLowerCase(),
    );
  }


  @override
  void dispose() {
    barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confirmed = participants.where((p) => p.status == "ACCEPTED").toList();
    final invited   = participants.where((p) => p.status == "INVITED").toList();
    final requests  = participants.where((p) => p.status == "REQUESTED").toList();
    final waitlist  = participants.where((p) => p.status == "WAITLIST").toList();

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
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        _mainTabButton("Participants", 0, isRootTab: true),
                        _mainTabButton("Details", 1),
                        _mainTabButton("Chat", 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 2),

            // --------- SECOND NAVBAR (MERGED WITH PARTICIPANTS) ----------
            if (mainTab == 0)
              Builder(
                builder: (_) => SlideTransition(
                  position: barOffset,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(22),
                              bottomRight: Radius.circular(22),
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          // ---- FIX OVERFLOW: horizontal scroll ----
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _reactionPill("Confirmed", 0, Colors.green),
                                const SizedBox(width: 10),
                                _reactionPill("Invited", 1, Colors.orange),
                                const SizedBox(width: 10),
                                _reactionPill("Requests", 2, Colors.blue),
                                const SizedBox(width: 10),
                                _reactionPill("Waitlist", 3, Colors.grey),
                              ],
                            ),
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
                  : _buildContent(confirmed, invited, requests, waitlist),
            ),


            // ---------- JOIN / LEAVE BUTTON (VISUAL ONLY) ----------
            if (mainTab == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    currentUsername == null
                        ? SizedBox.shrink()
                        : (
                        isUserParticipant()
                            ? _leaveButtonVisual()
                            : _joinButtonVisual()
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // MAIN NAVBAR BUTTONS
  // ----------------------------------------------------------
  Widget _mainTabButton(String label, int index, {bool isRootTab = false}) {
    bool selected = mainTab == index;

    BorderRadius radius = isRootTab
        ? const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    )
        : BorderRadius.circular(12);

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
            color: selected ? Colors.white.withOpacity(0.34) : Colors.transparent,
            borderRadius: radius,
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

  // ----------------------------------------------------------
  // SECOND NAVBAR — REACTION PILLS
  // ----------------------------------------------------------
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
            color: selected ? Colors.white : Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }


  // ----------------------------------------------------------
  // Join Button
  // ----------------------------------------------------------

  Widget _joinButtonVisual() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0A6F4A),
            Color(0xFF46C264),
          ],
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
      child: const Center(
        child: Text(
          "Join Match",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                blurRadius: 6,
                color: Colors.black26,
                offset: Offset(0, 2),
              )
            ],
          ),
        ),
      ),
    );
  }


  // ----------------------------------------------------------
// NEW — Leave Button
// ----------------------------------------------------------
  Widget _leaveButtonVisual() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFA30000),
            Color(0xFFE53935),
          ],
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
      child: const Center(
        child: Text(
          "Leave Match",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                blurRadius: 6,
                color: Colors.black26,
                offset: Offset(0, 2),
              )
            ],
          ),
        ),
      ),
    );
  }


  // ----------------------------------------------------------
  // MAIN CONTENT
  // ----------------------------------------------------------
  Widget _buildContent(
      List<Participant> confirmed,
      List<Participant> invited,
      List<Participant> requests,
      List<Participant> waitlist,
      ) {
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

  // ----------------------------------------------------------
  // USER LIST
  // ----------------------------------------------------------
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

  // ----------------------------------------------------------
  // USER CARD
  // ----------------------------------------------------------
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
