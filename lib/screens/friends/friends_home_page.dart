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

class _FriendsHomePageState extends State<FriendsHomePage> {
  late int tabIndex;

  final Color _bgDark = const Color(0xFF091210);
  final Color _accentGreen = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    tabIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.sports_soccer,
                size: 300,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Social",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getTitleForIndex(tabIndex),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.people_alt_outlined, color: Colors.white),
                      )
                    ],
                  ),
                ),

                Container(
                  height: 55,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13241E),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      _navItem(icon: Icons.people, index: 0),
                      _navItem(icon: Icons.search, index: 1),
                      _navItem(icon: Icons.call_received, index: 2),
                      _navItem(icon: Icons.call_made, index: 3),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey<int>(tabIndex),
                      child: _buildTabContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required int index}) {
    bool isSelected = tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? _accentGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF091210) : Colors.white54,
            size: 24,
          ),
        ),
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0: return "My Friends";
      case 1: return "Find People";
      case 2: return "Requests";
      case 3: return "Sent";
      default: return "Social";
    }
  }

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