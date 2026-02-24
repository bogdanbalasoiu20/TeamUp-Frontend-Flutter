import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/tournament_match.dart';
import 'package:team_up_fe_new/services/tournament_api.dart';

Future<void> showFinishMatchDialog({
  required BuildContext context,
  required TournamentMatchModel match,
  required VoidCallback onMatchFinished,
}) async {
  final TextEditingController homeController = TextEditingController();
  final TextEditingController awayController = TextEditingController();

  final Color bgDark = const Color(0xFF091210);
  final Color cardSurface = const Color(0xFF13241E);
  final Color accentGreen = const Color(0xFF00E676);
  final Color textSecondary = const Color(0xFF8A9E96);

  Future<void> submitScore(BuildContext context, String matchId, int homeScore, int awayScore) async {
    try {
      await TournamentApi.finishMatch(matchId, homeScore, awayScore);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Match finished successfully!", style: TextStyle(color: Colors.black)),
          backgroundColor: accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      onMatchFinished();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to finish match: $e", style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bgDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle modern
                Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Match Result",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentGreen.withOpacity(0.3)),
                      ),
                      child: Text(
                        "DAY ${match.matchDay}",
                        style: TextStyle(
                          color: accentGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Home Team
                      Expanded(
                        child: _modernScoreColumn(
                          controller: homeController,
                          teamName: match.homeTeamName,
                          accentGreen: accentGreen,
                          textSecondary: textSecondary,
                          bgDark: bgDark,
                          autofocus: true,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: bgDark,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Text(
                            "VS",
                            style: TextStyle(
                              color: textSecondary,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      // Away Team
                      Expanded(
                        child: _modernScoreColumn(
                          controller: awayController,
                          teamName: match.awayTeamName,
                          accentGreen: accentGreen,
                          textSecondary: textSecondary,
                          bgDark: bgDark,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.pop(sheetContext);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: textSecondary.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "CANCEL",
                          style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();

                          final int? homeScore = int.tryParse(homeController.text);
                          final int? awayScore = int.tryParse(awayController.text);

                          if (homeScore != null && awayScore != null && homeScore >= 0 && awayScore >= 0) {
                            Navigator.pop(sheetContext);
                            submitScore(context, match.id, homeScore, awayScore);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Please enter valid positive numbers"),
                                backgroundColor: Colors.red.shade900,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: accentGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "SAVE SCORE",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _modernScoreColumn({
  required TextEditingController controller,
  required String teamName,
  required Color accentGreen,
  required Color textSecondary,
  required Color bgDark,
  bool autofocus = false,
}) {
  return Column(
    children: [
      Text(
        teamName,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: 75,
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          cursorColor: accentGreen,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
          decoration: InputDecoration(
            hintText: "0",
            hintStyle: TextStyle(color: textSecondary.withOpacity(0.3)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            filled: true,
            fillColor: bgDark,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: accentGreen, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    ],
  );
}