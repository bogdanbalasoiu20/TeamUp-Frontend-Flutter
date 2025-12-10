import 'package:flutter/material.dart';
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
    if (loading) return const Center(child: CircularProgressIndicator());

    if (friends.isEmpty) {
      return const Center(
        child: Text(
          "You have no friends yet",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (_, i) {
        final f = friends[i];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(f.username, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            f.city ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
        );
      },
    );
  }
}
