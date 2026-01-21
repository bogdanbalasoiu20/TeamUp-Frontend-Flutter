import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';
import '../../services/friend_api.dart';
import '../../models/friend_request.dart';

class OutgoingRequestsTab extends StatefulWidget {
  const OutgoingRequestsTab({super.key});

  @override
  State<OutgoingRequestsTab> createState() => _OutgoingRequestsTabState();
}

class _OutgoingRequestsTabState extends State<OutgoingRequestsTab> {
  List<FriendRequest> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await FriendApi.getOutgoing();
    setState(() {
      requests = r;
      loading = false;
    });
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
          "No outgoing requests",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: requests.length,
        itemBuilder: (_, i) =>
            _requestTile(context, requests[i]),
      ),
    );
  }

  Widget _requestTile(BuildContext context, FriendRequest r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.35),
            child: const Icon(Icons.person, size: 36, color: Colors.white),
          ),

          const SizedBox(width: 16),

          // Username → open profile
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        UserProfilePage(username: r.addresseeUsername),
                  ),
                );
              },
              child: Text(
                r.addresseeUsername,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Status chip
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orangeAccent),
              color: Colors.orangeAccent.withOpacity(0.15),
            ),
            child: const Text(
              "Pending",
              style: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
