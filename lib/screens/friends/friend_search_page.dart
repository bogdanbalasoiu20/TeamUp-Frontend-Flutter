import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';
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

  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);

  Future<void> _search(String q) async {
    q = q.trim();

    if (q.isEmpty) {
      if (mounted) {
        setState(() {
          results = [];
          loading = false;
        });
      }
      return;
    }

    setState(() => loading = true);

    try {
      final r = await FriendApi.searchUsers(q);
      if (mounted) {
        setState(() {
          results = r;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _search(value),
              cursorColor: _accentGreen,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "Find users...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search, color: _accentGreen),
                filled: true,
                fillColor: _cardSurface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _accentGreen),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    _search("");
                  },
                )
                    : null,
              ),
            ),
          ),

          if (loading)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: CircularProgressIndicator(color: _accentGreen),
            ),

          if (!loading && results.isEmpty && _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 10),
                  Text(
                    "No users found",
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemBuilder: (context, i) => _friendResultTile(results[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendResultTile(UserSearchResult u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfilePage(username: u.username),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  backgroundImage: (u.photoUrl.isNotEmpty) ? NetworkImage(u.photoUrl) : null,
                  child: u.photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 28, color: Colors.white54)
                      : null,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    u.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                _buildActionButton(u),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(UserSearchResult u) {
    if (u.isFriend) {
      return _statusChip("Friends", _accentGreen);
    }

    if (u.pendingSent) {
      return _statusChip("Sent", Colors.orangeAccent);
    }

    if (u.pendingReceived) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconButton(Icons.check, _accentGreen, () async {
            await FriendApi.respond(u.id, true);
            _search(_searchController.text);
          }),
          const SizedBox(width: 8),
          _iconButton(Icons.close, Colors.redAccent, () async {
            await FriendApi.respond(u.id, false);
            _search(_searchController.text);
          }),
        ],
      );
    }

    return GestureDetector(
      onTap: () async {
        await FriendApi.sendRequest(u.id);
        _search(_searchController.text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _accentGreen,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _accentGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: const Text(
          "+ Add",
          style: TextStyle(
            color: Color(0xFF091210),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}