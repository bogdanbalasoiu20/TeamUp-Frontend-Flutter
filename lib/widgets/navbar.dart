import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/create_match_page.dart';
import 'package:team_up_fe_new/screens/discover_page.dart';
import 'package:team_up_fe_new/screens/friends/friends_home_page.dart';
import 'package:team_up_fe_new/screens/home_page.dart';
import 'package:team_up_fe_new/screens/idk_page.dart';
import 'package:team_up_fe_new/screens/match_map_page.dart';
import 'package:team_up_fe_new/screens/teams_page.dart';
import 'package:team_up_fe_new/screens/user_profile_page.dart';

class TeamUpNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const TeamUpNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      height: 58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navIcon(index: 0, icon: Icons.home_rounded),
          _navIcon(index: 1, icon: Icons.stadium),
          _centerCreateButton(),
          _navIcon(index: 3, icon: Icons.auto_awesome_rounded),
          _navIcon(index: 4, icon: Icons.pending_rounded
          ),
        ],
      ),
    );
  }

  Widget _navIcon({required int index, required IconData icon}) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        size: 24,
        color: isActive ? const Color(0xFF2E8B57) : Colors.grey.shade600,
      ),
    );
  }

  Widget _centerCreateButton() {
    return GestureDetector(
      onTap: () => onTabSelected(2),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFF003B2F),
              Color(0xFF0A6F4A),
              Color(0xFF46C264),
            ],
          ),
        ),
        child: const Icon(Icons.groups_rounded , color: Colors.white, size: 22),
      ),
    );
  }
}



class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 0;

  final pages = const [
    HomePage(),
    MatchesMapPage(),
    TeamsPage(),
    DiscoverPage(),
    IdkPage()
  ];

  void _onTabSelected(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: TeamUpNavBar(
        currentIndex: currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}



