import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/match_api.dart';
import 'package:team_up_fe_new/models/match.dart';

class MatchCardList extends StatelessWidget {
  final MatchItem match;

  const MatchCardList({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("yyyy-MM-dd HH:mm")
        .format(DateTime.parse(match.startsAt));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // left icon box
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.sports_soccer,
                color: Colors.green.shade700, size: 30),
          ),

          const SizedBox(width: 16),

          // text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF003B2F),
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  "${match.venueName}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  "Players: ${match.currentPlayers}/${match.maxPlayers}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade700,
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
