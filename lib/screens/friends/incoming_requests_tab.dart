import 'package:flutter/material.dart';
import '../../services/friend_api.dart';
import '../../models/friend_request.dart';
import '../profile/user_profile_page.dart';

class IncomingRequestsTab extends StatefulWidget {
  const IncomingRequestsTab({super.key});

  @override
  State<IncomingRequestsTab> createState() => _IncomingRequestsTabState();
}

class _IncomingRequestsTabState extends State<IncomingRequestsTab> {
  List<FriendRequest> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await FriendApi.getIncoming();
    setState(() {
      requests = r;
      loading = false;
    });
  }

  Future<void> _respond(String id, bool accept) async {
    await FriendApi.respond(id, accept);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF003B2F),
            Color(0xFF0A6F4A),
            Color(0xFF062D24),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : requests.isEmpty
          ? const Center(
        child: Text(
          "No incoming requests",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (_, i) =>
            _swipeableTile(context, requests[i]),
      ),
    );
  }

  Widget _swipeableTile(BuildContext context, FriendRequest r) {
    return Column(
      children: [
        // --- Hint text ---
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            "Swipe right to accept · Swipe left to decline",
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Dismissible(
          key: Key(r.id),

          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              await _respond(r.id, true);
            } else {
              await _respond(r.id, false);
            }
            return true;
          },

          // ---- ACCEPT BACKGROUND (SWIPE RIGHT) ----
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF2ECC71).withOpacity(0.25),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 26),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 34),
                SizedBox(width: 10),
                Text(
                  "Accept",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ---- DECLINE BACKGROUND (SWIPE LEFT) ----
          secondaryBackground: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.red,
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  "Decline",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.cancel, color: Colors.white, size: 34),
              ],
            ),
          ),

          child: _requestCard(context, r),
        ),
      ],
    );
  }


  Widget _requestCard(BuildContext context, FriendRequest r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
        ),
      ),
      child: Row(
        children: [
          // avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.28),
            child: const Icon(Icons.person, size: 32, color: Colors.white),
          ),

          const SizedBox(width: 16),

          // username + click
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        UserProfilePage(username: r.requesterUsername),
                  ),
                );
              },
              child: Text(
                r.requesterUsername,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // hint icon
          Icon(Icons.swipe, color: Colors.white70, size: 22),
        ],
      ),
    );
  }
}
