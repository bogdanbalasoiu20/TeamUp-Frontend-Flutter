import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/matches/finish_match_screen.dart';
import 'package:team_up_fe_new/screens/friends/friends_home_page.dart';
import 'package:team_up_fe_new/screens/match_participants/match_participants_page.dart';
import 'package:team_up_fe_new/screens/ratings/rate_match_players_page.dart';
import 'package:team_up_fe_new/services/match_api.dart';
import '../../services/notifications_api.dart';
import '../../models/notification_item.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> notifications = [];
  bool loading = true;

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardRead = const Color(0xFF13241E);
  final Color _cardUnread = const Color(0xFF1A382E);
  final Color _accentGreen = const Color(0xFF00E676);

  // Notification Type Colors
  final Color _colorMatch = const Color(0xFF00E676);
  final Color _colorFriend = const Color(0xFF2979FF);
  final Color _colorAlert = const Color(0xFFFF3D00);
  final Color _colorRating = const Color(0xFFFFD600);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await NotificationsApi.fetchAll();
      setState(() {
        notifications = list;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }


  void _handleNotificationTap(NotificationItem n) async {
    if (!n.isSeen) {
      setState(() => n.isSeen = true);
      await NotificationsApi.markAsSeen(n.id);
    }

    if (!mounted) return;

    switch (n.type) {
      case "FRIEND_REQUEST_RECEIVED":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsHomePage(initialTab: 2)));
        break;
      case "FRIEND_REQUEST_ACCEPTED":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsHomePage(initialTab: 0)));
        break;
      case "JOIN_REQUEST_RECEIVED":
      case "JOIN_REQUEST_ACCEPTED":
      case "JOIN_WAITLIST":
      case "PROMOTED_FROM_WAITLIST":
      case "MOVED_TO_WAITLIST":
      case "MATCH_LEFT":
      case "MATCH_INVITE_RECEIVED":
      case "MATCH_INVITE_ACCEPTED":
      case "MATCH_UPDATED":
      case "MATCH_STARTING_SOON":
      case "MATCH_CANCELLED":
        if (n.matchId != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MatchOverviewPage(matchId: n.matchId!)));
        }
        break;
      case "MATCH_FINISH_CONFIRMATION":
        if (n.matchId != null) {
          _handleFinishMatchRedirect(n.matchId!);
        }
        break;
      case "MATCH_RATING":
        if (n.matchId != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RateMatchPlayersPage(matchId: n.matchId!)));
        }
        break;
      default:
        debugPrint("Unhandled type: ${n.type}");
    }
  }

  Future<void> _handleFinishMatchRedirect(String matchId) async {
    try {
      final match = await MatchApi.fetchMatchDetails(matchId);
      if (match.status == "DONE") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Match already finished")));
        return;
      }
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => FinishMatchScreen(match: match)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error loading match")));
    }
  }


  ({IconData icon, Color color}) _getStyleFor(String type) {
    switch (type) {
      case "FRIEND_REQUEST_RECEIVED":
      case "FRIEND_REQUEST_ACCEPTED":
        return (icon: Icons.person_add_rounded, color: _colorFriend);

      case "MATCH_RATING":
        return (icon: Icons.star_rounded, color: _colorRating);

      case "MATCH_CANCELLED":
      case "MATCH_LEFT":
        return (icon: Icons.warning_rounded, color: _colorAlert);

      case "MATCH_FINISH_CONFIRMATION":
        return (icon: Icons.sports_score_rounded, color: _colorRating);

      case "MATCH_UPDATED":
        return (icon: Icons.edit_calendar_rounded, color: Colors.tealAccent);

      default:
        return (icon: Icons.sports_soccer_rounded, color: _colorMatch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Inbox",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  if (notifications.any((n) => !n.isSeen))
                    Icon(Icons.mark_email_read_rounded, color: Colors.white.withOpacity(0.5), size: 24),
                ],
              ),
            ),

            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator(color: _accentGreen))
                  : notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: notifications.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildNotificationItem(notifications[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem n) {
    final style = _getStyleFor(n.type);
    final bool isUnread = !n.isSeen;

    return GestureDetector(
      onTap: () => _handleNotificationTap(n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isUnread ? _cardUnread : _cardRead,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? _accentGreen.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
          boxShadow: isUnread
              ? [BoxShadow(color: _accentGreen.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //INDICATOR DOT (only for unread)
              if (isUnread)
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 12),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _accentGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: _accentGreen.withOpacity(0.6), blurRadius: 6),
                      ],
                    ),
                  ),
                ),

              //  ICON BOX
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: style.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(style.icon, color: style.color, size: 24),
              ),

              const SizedBox(width: 16),

              // TEXT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              color: isUnread ? Colors.white : Colors.white70,
                              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          n.timeAgo,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isUnread ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded, size: 40, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            "All caught up!",
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "You have no new notifications.",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
          ),
        ],
      ),
    );
  }
}