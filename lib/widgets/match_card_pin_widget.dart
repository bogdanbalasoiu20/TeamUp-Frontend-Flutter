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
    final String dayNumber = DateFormat("dd").format(start);
    final String monthName = DateFormat("MMM").format(start).toUpperCase();
    final String timeStr = DateFormat("HH:mm").format(start);

    final bool isFull = match.joinedPlayers >= match.maxPlayers;

    const Color bgDark = Color(0xFF091210);
    const Color cardSurface = Color(0xFF13241E);
    const Color accentGreen = Color(0xFF00E676);
    const Color textSecondary = Color(0xFF8A9E96);

    final Color mainColor = isFull ? textSecondary : accentGreen;

    final double fillPercent = (match.joinedPlayers / match.maxPlayers).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MatchOverviewPage(matchId: match.id),
              ),
            );
          },
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        mainColor.withOpacity(0.08),
                        Colors.transparent
                      ],
                      center: Alignment.topRight,
                      radius: 1.0,
                    ),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
                  ),
                ),
              ),

              Positioned(
                right: -20,
                bottom: -10,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.sports_soccer,
                    size: 140,
                    color: Colors.white.withOpacity(0.02),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 65,
                          decoration: BoxDecoration(
                            color: bgDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                monthName,
                                style: TextStyle(color: mainColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                dayNumber,
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      match.title,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: mainColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: mainColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      match.totalPrice == 0 ? "FREE" : "${match.totalPrice.toInt()} LEI",
                                      style: TextStyle(
                                        color: mainColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded, color: textSecondary, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "Locație necunoscută",
                                      style: TextStyle(color: textSecondary, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, color: textSecondary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeStr,
                                    style: TextStyle(color: textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    const SizedBox(height: 16),

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
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        height: 28,
                                        child: Stack(
                                          children: [
                                            _buildAvatarMock(0, Colors.blueGrey, cardSurface),
                                            _buildAvatarMock(16, Colors.deepPurple, cardSurface),
                                            _buildAvatarMock(32, Colors.orange, cardSurface),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "+ ${match.joinedPlayers} joined",
                                        style: TextStyle(color: textSecondary, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${match.joinedPlayers} / ${match.maxPlayers}",
                                    style: TextStyle(
                                        color: isFull ? Colors.white70 : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Stack(
                                children: [
                                  // Background bar
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  // Fill bar
                                  AnimatedFractionallySizedBox(
                                    duration: const Duration(milliseconds: 500),
                                    widthFactor: fillPercent,
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: mainColor.withOpacity(0.4),
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

                        const SizedBox(width: 20),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarMock(double leftPos, Color color, Color borderColor) {
    return Positioned(
      left: leftPos,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: const Icon(Icons.person, size: 16, color: Colors.white70),
      ),
    );
  }
}