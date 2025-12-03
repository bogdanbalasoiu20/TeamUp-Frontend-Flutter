import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/match_api.dart';
import '../screens/match_participants_page.dart';
import 'package:team_up_fe_new/models/match.dart';

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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- TITLE ----------------
          Row(
            children: [
              Expanded(
                child: Text(
                  match.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),

          const SizedBox(height: 6),

          // ---------------- DATE & TIME ----------------
          Row(
            children: [
              Icon(Icons.access_time, size: 17, color: Colors.white70),
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

          const SizedBox(height: 12),

          // ---------------- PLAYERS & DURATION ----------------
          Row(
            children: [
              Icon(Icons.sports_soccer, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                "${match.joinedPlayers}/${match.maxPlayers} players",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(width: 18),

              Icon(Icons.timer, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                "${match.durationMinutes} min",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ---------------- PRICE ----------------
          Row(
            children: [
              Icon(Icons.payments, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                "${match.totalPrice.toStringAsFixed(0)} lei",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ---------------- VIEW MATCH BUTTON ----------------
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              label: const Text(
                "View Match",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MatchOverviewPage(matchId: match.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
