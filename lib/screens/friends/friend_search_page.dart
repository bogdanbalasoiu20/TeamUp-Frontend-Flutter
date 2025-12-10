import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/user_profile_page.dart';
import '../../models/user_search_result.dart';
import '../../services/friend_api.dart';

class FriendSearchPage extends StatefulWidget {
  const FriendSearchPage({super.key});

  @override
  State<FriendSearchPage> createState() => _FriendSearchPageState();
}

class _FriendSearchPageState extends State<FriendSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserSearchResult> results = [];
  bool loading = false;

  Future<void> _search(String q) async {
    q = q.trim();

    if (q.isEmpty) {
      setState(() {
        results = [];
        loading = false;
      });
      return;
    }

    setState(() => loading = true);

    try {
      final r = await FriendApi.searchUsers(q);
      setState(() {
        results = r;
        loading = false;
      });
    } catch (e) {
      print("Search error: $e");
      setState(() => loading = false);
    }
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
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text(
            "Add Friends",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.black.withOpacity(0.15),
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),

        body: Column(
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  print("Search typed: '$value'");
                  _search(value);
                },
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search users...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  fillColor: Colors.white.withOpacity(0.25),
                  filled: true,
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(color: Colors.white),
              ),

            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, i) => _friendResultTile(results[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FRIEND TILE (FĂRĂ BLUR)
  Widget _friendResultTile(UserSearchResult u) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfilePage(username: u.username),
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
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withOpacity(0.35),
              backgroundImage:
              (u.photoUrl.isNotEmpty) ? NetworkImage(u.photoUrl) : null,
              child: u.photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 36, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                u.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            _friendActionButton(u),
          ],
        ),
      ),
    );
  }


  // BUTTON LOGIC
  Widget _friendActionButton(UserSearchResult u) {
    if (u.isFriend) {
      return _statusChip("Friends", Colors.greenAccent);
    }

    if (u.pendingSent) {
      return _statusChip("Pending", Colors.orangeAccent);
    }

    if (u.pendingReceived) {
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.greenAccent),
            onPressed: () async {
              await FriendApi.respond(u.id, true);
              _search(_searchController.text);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () async {
              await FriendApi.respond(u.id, false);
              _search(_searchController.text);
            },
          )
        ],
      );
    }

    return ElevatedButton(
      onPressed: () async {
        await FriendApi.sendRequest(u.id);
        _search(_searchController.text);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF46C264),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const Text(
        "Add",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // STATUS CHIP
  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
        color: color.withOpacity(0.15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
