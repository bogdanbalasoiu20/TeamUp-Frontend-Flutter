import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/main_pages/home_page.dart';
import 'package:team_up_fe_new/screens/map/match_map_page.dart';
import 'package:team_up_fe_new/screens/team/teams_page.dart';
import 'package:team_up_fe_new/screens/tournament/tournaments_page.dart';

class TeamUpNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);

  const TeamUpNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardSurface,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(index: 0, icon: Icons.home_rounded, label: "Home"),
              _navItem(index: 1, icon: Icons.map_outlined, label: "Map"),
              _navItem(index: 2, icon: Icons.groups_rounded, label: "Teams"),
              _navItem(index: 3, icon: Icons.emoji_events_rounded, label: "Tourney"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({required int index, required IconData icon, required String label}) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _accentGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? _accentGreen : Colors.white54,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? _accentGreen : Colors.white54,
              ),
            ),
          ],
        ),
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
    TournamentsPage(),
  ];

  void _onTabSelected(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091210),
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