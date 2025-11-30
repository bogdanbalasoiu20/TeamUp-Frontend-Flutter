import 'package:flutter/material.dart';
import '../services/match_api.dart';
import '../widgets/match_card_widget.dart';

class MatchesListPage extends StatefulWidget {
  const MatchesListPage({super.key});

  @override
  State<MatchesListPage> createState() => _MatchesListPageState();
}

class _MatchesListPageState extends State<MatchesListPage> {
  List<MatchItem> matches = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    setState(() => loading = true);

    final result = await MatchApi.getAllMatches();

    setState(() {
      matches = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Matches"),
        backgroundColor: const Color(0xFF003B2F),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (_, index) {
          return MatchCardList(match: matches[index]);
        },
      ),
    );
  }
}
