import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/match_info.dart';
import 'package:team_up_fe_new/screens/matches/finish_match_screen.dart';
import 'package:team_up_fe_new/services/match_api.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver {

  bool _finishScreenOpened = false;
  bool _checkingFinishMatch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFinishMatchPrompt();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkFinishMatchPrompt();
    }
  }

  Future<void> _checkFinishMatchPrompt() async {
    if (_finishScreenOpened || _checkingFinishMatch) return;

    _checkingFinishMatch = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      if (token == null) return;

      final pending = await MatchApi.getOldestFinishPendingMatch();
      if (pending == null) return;

      final match = await MatchApi.fetchMatchDetails(pending.id);

      debugPrint("AUTO FINISH MATCH:");
      debugPrint("id=${match.id}");
      debugPrint("creator=${match.creatorId}");
      debugPrint("status=${match.status}");

      _finishScreenOpened = true;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => FinishMatchScreen(match: match),
        ),
      );

      _finishScreenOpened = false;

      if (result == true) {
        _checkFinishMatchPrompt();
      }

    } catch (e) {
      debugPrint("Finish match check failed: $e");
    } finally {
      _checkingFinishMatch = false;
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
