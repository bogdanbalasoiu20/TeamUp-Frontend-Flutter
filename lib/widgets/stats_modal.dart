import 'package:flutter/material.dart';

class PlayerStatsModalContent extends StatelessWidget {
  const PlayerStatsModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

        const Text(
          "Player Statistics(TEST)",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        _statRow("Matches played", "42"),
        _statRow("Win rate", "61%"),
        _statRow("Goals", "18"),
        _statRow("Assists", "12"),
        _statRow("Best position", "MID"),

        const SizedBox(height: 30),

        const Text(
          "More stats & charts coming soon 👀",
          style: TextStyle(color: Colors.white60),
        ),
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
