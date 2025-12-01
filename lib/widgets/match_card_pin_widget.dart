import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/match_api.dart';

class MatchCardPin extends StatelessWidget {
  final MatchPin match;

  const MatchCardPin({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("EEEE, dd MMM • HH:mm")
        .format(DateTime.parse(match.startsAt));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF003B2F),
            const Color(0xFF0A5444),
            const Color(0xFF2E8B57).withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ----------- ICON LEFT (large) ----------
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(width: 16),

          // ----------- TEXT AREA ----------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 17, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ---------- BADGE ----------
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Players: ${match.joinedPlayers}/${match.maxPlayers}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
