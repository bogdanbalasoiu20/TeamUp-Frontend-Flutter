import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';
import 'package:team_up_fe_new/widgets/custom_avatar.dart';
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

  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await FriendApi.getOutgoing();
    if (mounted) {
      setState(() {
        requests = r;
        loading = false;
      });
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
              child: Icon(Icons.outbox_rounded, size: 48, color: Colors.white.withOpacity(0.2)),
            ),
            const SizedBox(height: 16),
            const Text(
              "No outgoing requests",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              "Requests you send will appear here",
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfilePage(username: r.addresseeUsername),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CustomAvatar(
                  photoUrl: r.addresseePhotoUrl,
                  radius: 25,
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.addresseeUsername,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Waiting for response...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
                    color: Colors.orangeAccent.withOpacity(0.1),
                  ),
                  child: const Text(
                    "Pending",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}