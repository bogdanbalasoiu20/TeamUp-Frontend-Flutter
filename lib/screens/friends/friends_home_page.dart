import 'dart:ui';
import 'package:flutter/material.dart';

import '../friends/friends_tab.dart';
import '../friends/incoming_requests_tab.dart';
import '../friends/outgoing_requests_tab.dart';
import 'friend_search_page.dart';

class FriendsHomePage extends StatefulWidget {
  final int initialTab;

  const FriendsHomePage({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<FriendsHomePage> createState() => _FriendsHomePageState();
}

class _FriendsHomePageState extends State<FriendsHomePage>
    with TickerProviderStateMixin {

  late int tabIndex;

  @override
  void initState() {
    super.initState();
    tabIndex = widget.initialTab;
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
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text(
            "Friends",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black45,
                  offset: Offset(0, 2),
                )
              ],
            ),
          ),
          centerTitle: true,
        ),

        body: Column(
          children: [
            // ⭐ NAVBAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        _navButton("Friends", 0),
                        _navButton("Search", 1),
                        _navButton("Incoming", 2),
                        _navButton("Outgoing", 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  //NAV BUTTON
  Widget _navButton(String label, int idx) {
    bool selected = tabIndex == idx;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tabIndex = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white.withOpacity(0.34) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(selected ? 1 : 0.8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  //TAB CONTENT
  Widget _buildTabContent() {
    switch (tabIndex) {
      case 0:
        return const FriendsTab();
      case 1:
        return const FriendSearchPage();
      case 2:
        return const IncomingRequestsTab();
      case 3:
        return const OutgoingRequestsTab();
      default:
        return const SizedBox.shrink();
    }
  }
}
