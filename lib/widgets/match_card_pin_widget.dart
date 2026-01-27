import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/match_participants/match_participants_page.dart';
import 'package:team_up_fe_new/models/match.dart';

class MatchCardPin extends StatelessWidget {
  final MatchPin match;

  const MatchCardPin({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final DateTime start = DateTime.parse(match.startsAt);
    final String dayNumber = DateFormat("d").format(start);
    final String monthName = DateFormat("MMM").format(start).toUpperCase();
    final String timeStr = DateFormat("HH:mm").format(start);

    const Color cardBg = Color(0xFF101F1A);
    const Color cardSurface = Color(0xFF1A2E28);
    const Color accentGreen = Color(0xFF00E676);
    const Color textGrey = Colors.white54;

    final double fillPercent = (match.joinedPlayers / match.maxPlayers).clamp(0.0, 1.0);

    return Container(
      height: 165,
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),

          Positioned(
            right: -30,
            bottom: -20,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.sports_soccer,
                size: 160,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  decoration: BoxDecoration(
                      color: cardSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))
                      ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          monthName,
                          style: TextStyle(
                            color: accentGreen.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      Text(
                        dayNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF091410),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: accentGreen.withOpacity(0.3),
                              width: 1
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 10, color: accentGreen),
                            const SizedBox(width: 4),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          Icon(Icons.place_rounded, size: 14, color: accentGreen.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Locație necunoscută",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: textGrey, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Players",
                                      style: TextStyle(color: textGrey, fontSize: 11),
                                    ),
                                    Text(
                                      "${match.joinedPlayers}/${match.maxPlayers}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Stack(
                                  children: [
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    AnimatedFractionallySizedBox(
                                      duration: const Duration(milliseconds: 500),
                                      widthFactor: fillPercent,
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: accentGreen,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: accentGreen.withOpacity(0.6),
                                              blurRadius: 6,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 14),

                          Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: accentGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: accentGreen.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  match.totalPrice == 0
                                      ? "FREE"
                                      : "${match.totalPrice.toInt()} LEI",
                                  style: TextStyle(
                                    color: match.totalPrice == 0 ? accentGreen : Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: accentGreen,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                splashColor: accentGreen.withOpacity(0.1),
                highlightColor: accentGreen.withOpacity(0.05),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchOverviewPage(matchId: match.id),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}