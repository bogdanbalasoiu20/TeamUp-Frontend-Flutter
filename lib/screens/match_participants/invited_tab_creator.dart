import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';
import '../../../models/invitable_friend.dart';
import '../../../models/participant.dart';
import '../../../services/match_participant_api.dart';
import '../../../utils/top_banner.dart';

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

  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

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
          cardSurface: _cardSurface,
          accentGreen: _accentGreen,
          textSecondary: _textSecondary,
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
            cardSurface: _cardSurface,
            accentGreen: _accentGreen,
            textSecondary: _textSecondary,
          )
              : _InvitedPlayersList(
            participants: widget.invitedParticipants,
            cardSurface: _cardSurface,
            accentGreen: _accentGreen,
            textSecondary: _textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SubTabs extends StatelessWidget {
  final int selected;
  final Function(int) onChange;
  final Color cardSurface;
  final Color accentGreen;
  final Color textSecondary;

  const _SubTabs({
    required this.selected,
    required this.onChange,
    required this.cardSurface,
    required this.accentGreen,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            _tab("Invite friends", 0),
            _tab("Invited players", 1),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final active = selected == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChange(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? accentGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
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
  final Color cardSurface;
  final Color accentGreen;
  final Color textSecondary;

  const _InviteFriendsList({
    required this.friends,
    required this.loading,
    required this.onSearch,
    required this.onInvite,
    required this.cardSurface,
    required this.accentGreen,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              cursorColor: accentGreen,
              decoration: InputDecoration(
                hintText: "Search friends...",
                hintStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.search, color: textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: onSearch,
            ),
          ),
        ),
        Expanded(
          child: loading
              ? Center(child: CircularProgressIndicator(color: accentGreen))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
                border: Border.all(color: accentGreen.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.person,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                f.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            f.invited
                ? Text(
              "Invited",
              style: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            )
                : SizedBox(
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () => onInvite(f),
                child: const Text(
                  "Invite",
                  style: TextStyle(fontWeight: FontWeight.bold),
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
  final Color cardSurface;
  final Color accentGreen;
  final Color textSecondary;

  const _InvitedPlayersList({
    required this.participants,
    required this.cardSurface,
    required this.accentGreen,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 48, color: textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "No invited players yet",
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3),
                    border: Border.all(color: accentGreen.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    p.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: textSecondary.withOpacity(0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}