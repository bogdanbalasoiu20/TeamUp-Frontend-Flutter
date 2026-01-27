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

  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _errorRed = const Color(0xFFFF5252);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await FriendApi.getIncoming();
    if (mounted) {
      setState(() {
        requests = r;
        loading = false;
      });
    }
  }

  Future<void> _respond(String id, bool accept) async {
    setState(() {
      requests.removeWhere((r) => r.id == id);
    });

    try {
      await FriendApi.respond(id, accept);
    } catch (e) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator(color: _accentGreen));
    }

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.white.withOpacity(0.2)),
            ),
            const SizedBox(height: 16),
            const Text(
              "No new requests",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              "You're all caught up!",
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: requests.length,
      itemBuilder: (_, i) => _requestTile(context, requests[i]),
    );
  }

  Widget _requestTile(BuildContext context, FriendRequest r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfilePage(username: r.requesterUsername),
                ),
              );
            },
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: const Icon(Icons.person, size: 30, color: Colors.white),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.requesterUsername,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Wants to be friends",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              _actionButton(
                icon: Icons.close,
                color: _errorRed,
                onTap: () => _respond(r.id, false),
              ),
              const SizedBox(width: 12),
              _actionButton(
                icon: Icons.check,
                color: _accentGreen,
                onTap: () => _respond(r.id, true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}