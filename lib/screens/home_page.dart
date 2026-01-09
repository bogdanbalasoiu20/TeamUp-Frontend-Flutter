import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/models/match_info.dart';
import 'package:team_up_fe_new/services/match_api.dart';
import 'package:team_up_fe_new/screens/finish_match_screen.dart';
import 'package:team_up_fe_new/models/match.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    _checkFinishMatchPrompt();
  }

  Future<void> _checkFinishMatchPrompt() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final loggedUserId = prefs.getString("user_id");
    if (loggedUserId == null) return;

    final matches = await MatchApi.getAllMatches();
    final now = DateTime.now().toUtc();

    for (final m in matches) {
      // ⚠️ cerem DIRECT MatchInfo
      final MatchInfo info = await MatchApi.fetchMatchDetails(m.id);

      if (info.creatorId != loggedUserId) continue;
      if (info.status == "DONE") continue;

      final end = info.startsAt
          .toUtc()
          .add(Duration(minutes: info.durationMinutes));

      if (!now.isAfter(end)) continue;

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FinishMatchScreen(matchId: info.id),
        ),
      );

      return;
    }
  }




  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Home page coming soon",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
