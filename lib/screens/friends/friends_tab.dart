import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';
import '../../services/friend_api.dart';
import '../../models/friendship.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  List<Friendship> friends = [];
  bool loading = true;

  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await FriendApi.getFriends();
    if (mounted) {
      setState(() {
        friends = r;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(
          color: _accentGreen,
          strokeWidth: 2,
        ),
      );
    }

    if (friends.isEmpty) {
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
              child: Icon(
                Icons.people_outline,
                size: 48,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No friends yet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Start adding people to build your squad",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: friends.length,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemBuilder: (_, i) {
        final f = friends[i];
        return _friendTile(f);
      },
    );
  }

  Widget _friendTile(Friendship f) {
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
          splashColor: _accentGreen.withOpacity(0.1),
          highlightColor: _accentGreen.withOpacity(0.05),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfilePage(username: f.username),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _accentGreen.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.person, size: 28, color: Colors.white70),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Tap to view profile",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: _accentGreen.withOpacity(0.8),
                    size: 18,
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