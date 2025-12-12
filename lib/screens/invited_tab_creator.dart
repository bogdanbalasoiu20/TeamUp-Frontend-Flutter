import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/user_profile_page.dart';
import '../../models/invitable_friend.dart';
import '../../models/participant.dart';
import '../../services/match_participant_api.dart';
import '../../utils/top_banner.dart';

class InvitedTabCreator extends StatefulWidget {
  final String matchId;
  final List<Participant> invitedParticipants;
  final Future<void> Function() onInviteSent;

  const InvitedTabCreator({
    super.key,
    required this.matchId,
    required this.invitedParticipants,
    required this.onInviteSent,
  });

  @override
  State<InvitedTabCreator> createState() => _InvitedTabCreatorState();
}

class _InvitedTabCreatorState extends State<InvitedTabCreator> {
  int subTab = 0; // 0 = invite friends, 1 = invited players
  List<InvitableFriend> friends = [];
  bool loading = false;
  String search = "";

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends({String? q}) async {
    setState(() => loading = true);
    final res = await MatchParticipantApi.fetchInvitableFriends(
      widget.matchId,
      search: q,
    );
    setState(() {
      friends = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SubTabs(
          selected: subTab,
          onChange: (i) => setState(() => subTab = i),
        ),
        Expanded(
          child: subTab == 0
              ? _InviteFriendsList(
            friends: friends,
            loading: loading,
            onSearch: (v) {
              search = v;
              _loadFriends(q: v);
            },
            onInvite: (f) async {
              await MatchParticipantApi.inviteUser(
                widget.matchId,
                f.userId,
              );

              await widget.onInviteSent();
              await _loadFriends(q: search);

              showTopBanner(
                context,
                "Invite sent to ${f.username}",
              );
            },
          )
              : _InvitedPlayersList(
            participants: widget.invitedParticipants,
          ),
        ),
      ],
    );
  }
}

class _SubTabs extends StatelessWidget {
  final int selected;
  final Function(int) onChange;

  const _SubTabs({
    required this.selected,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _tab("Invite friends", 0),
          _tab("Invited players", 1),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final active = selected == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChange(index),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withOpacity(0.35)
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteFriendsList extends StatelessWidget {
  final List<InvitableFriend> friends;
  final bool loading;
  final Function(String) onSearch;
  final Function(InvitableFriend) onInvite;

  const _InviteFriendsList({
    required this.friends,
    required this.loading,
    required this.onSearch,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search friends",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: onSearch,
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: friends.length,
            itemBuilder: (_, i) {
              final f = friends[i];
              return _inviteFriendCard(context, f, onInvite);
            },
          ),
        ),
      ],
    );
  }

  Widget _inviteFriendCard(
      BuildContext context,
      InvitableFriend f,
      Function(InvitableFriend) onInvite,
      ) {
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
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.35),
              child: const Icon(Icons.person,
                  size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                f.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            f.invited
                ? Text(
              "Invited",
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontWeight: FontWeight.w700,
              ),
            )
                : GestureDetector(
              onTap: () => onInvite(f),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0A6F4A),
                      Color(0xFF46C264),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  "Invite",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitedPlayersList extends StatelessWidget {
  final List<Participant> participants;

  const _InvitedPlayersList({required this.participants});

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const Center(
        child: Text(
          "No users here",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: participants.length,
      itemBuilder: (_, i) {
        final p = participants[i];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    UserProfilePage(username: p.username),
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
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.35),
                  child: const Icon(Icons.person,
                      size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    p.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
