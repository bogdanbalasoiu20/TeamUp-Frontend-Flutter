import 'package:flutter/material.dart';

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
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
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
        height: 58, // 🔥 compact navbar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(index: 0, icon: Icons.home_rounded),
            _navIcon(index: 1, icon: Icons.search_rounded),
            _centerCreateButton(),
            _navIcon(index: 3, icon: Icons.people_alt_rounded),
            _navIcon(index: 4, icon: Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _navIcon({required int index, required IconData icon}) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Icon(
        icon,
        size: 24, // 🔥 reduced
        color: isActive ? const Color(0xFF2E8B57) : Colors.grey.shade600,
      ),
    );
  }

  Widget _centerCreateButton() {
    return GestureDetector(
      onTap: () => onTabSelected(2),
      child: Container(
        padding: const EdgeInsets.all(10), // 🔥 reduced
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFF003B2F),
              Color(0xFF0A6F4A),
              Color(0xFF46C264),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent,
              blurRadius: 6, // 🔥 reduced
              offset: Offset(0, 3),
            )
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 22, // 🔥 reduced
        ),
      ),
    );
  }
}
