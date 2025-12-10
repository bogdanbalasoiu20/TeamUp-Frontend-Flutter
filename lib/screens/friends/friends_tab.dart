import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/user_profile_page.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await FriendApi.getFriends();
    setState(() {
      friends = r;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friends.isEmpty) {
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
        child: const Center(
          child: Text(
            "You have no friends yet",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

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
      child: ListView.builder(
        itemCount: friends.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemBuilder: (_, i) {
          final f = friends[i];
          return _friendTile(f);
        },
      ),
    );
  }


  Widget _friendTile(Friendship f) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfilePage(username: f.username),
          ),
        );
      },
      child: Container(
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
            // Avatar simplu
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withOpacity(0.35),
              child: const Icon(Icons.person, size: 36, color: Colors.white),
            ),

            const SizedBox(width: 16),

            // USERNAME
            Expanded(
              child: Text(
                f.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }
}
