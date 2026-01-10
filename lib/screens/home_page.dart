import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/match_info.dart';
import 'package:team_up_fe_new/screens/finish_match_screen.dart';
import 'package:team_up_fe_new/services/match_api.dart';

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

    // mic delay pentru context stabil
    Future.delayed(const Duration(milliseconds: 300), () {
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
      final match = await MatchApi.getOldestFinishPendingMatch();
      if (match == null) return;

      _finishScreenOpened = true;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => FinishMatchScreen(matchId: match.id),
        ),
      );

      // daca a finalizat un meci, verificam dacă mai exista altele
      if (result == true) {
        _finishScreenOpened = false;
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
