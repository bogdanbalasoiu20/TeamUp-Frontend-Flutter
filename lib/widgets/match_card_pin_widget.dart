import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/match_api.dart';

class MatchCardPin extends StatelessWidget {
  final MatchPin match;

  const MatchCardPin({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("EEE, dd MMM • HH:mm")
        .format(DateTime.parse(match.startsAt).toLocal());

    final progress = match.joinedPlayers / match.maxPlayers;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ---------- TOP ROW ----------
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF16A34A), Color(0xFF065F46)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.sports_soccer,
                    size: 32, color: Colors.white),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  match.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF003B2F),
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 14),

          /// ---------- DATE ----------
          Row(
            children: [
              const Icon(Icons.schedule, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// ---------- PLAYERS ----------
          Text(
            "Players: ${match.joinedPlayers}/${match.maxPlayers}",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          /// ---------- PROGRESS BAR ----------
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(
                progress < 1
                    ? const Color(0xFF16A34A)
                    : Colors.redAccent,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// -------- BUTTON JOIN --------
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003B2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "VIEW MATCH",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
