import 'package:flutter/material.dart';
import '../../services/friend_api.dart';
import '../../models/friend_request.dart';
import '../user_profile_page.dart';

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

          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfilePage(username: r.requesterUsername),
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

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.greenAccent),
                onPressed: () => _respond(r.id, true),
              ),

              IconButton(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                onPressed: () => _respond(r.id, false),
              )
            ],
          )
        ],
      ),
    );
  }
}
