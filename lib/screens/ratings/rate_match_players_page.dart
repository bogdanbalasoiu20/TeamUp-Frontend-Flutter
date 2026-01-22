import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/player_rating_draft.dart';
import 'package:team_up_fe_new/models/player_to_rate.dart';
import 'package:team_up_fe_new/services/player_rating_api.dart';

class RateMatchPlayersPage extends StatefulWidget {
  final String matchId;

  const RateMatchPlayersPage({super.key, required this.matchId});

  @override
  State<RateMatchPlayersPage> createState() => _RateMatchPlayersPageState();
}

class _RateMatchPlayersPageState extends State<RateMatchPlayersPage> {
  late Future<List<PlayerToRateModel>> _playersFuture;

  final Map<String, PlayerRatingDraft> _drafts = {};

  @override
  void initState() {
    super.initState();
    print("RATE PAGE matchId = ${widget.matchId}");
    _playersFuture =
        PlayerRatingService.getPlayersToRate(widget.matchId);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rate Players")),
      body: FutureBuilder<List<PlayerToRateModel>>(
        future: _playersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final players = snapshot.data!;

          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (_, i) {
              final p = players[i];
              return ListTile(
                title: Text(p.username),
                subtitle: Text(p.position),
                trailing: Icon(
                  _drafts.containsKey(p.userId)
                      ? Icons.check_circle
                      : Icons.edit,
                ),
                onTap: () => _openRatingSheet(p),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submit,
        label: const Text("Submit Ratings"),
        icon: const Icon(Icons.send),
      ),
    );
  }


  void _openRatingSheet(PlayerToRateModel player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Rate ${player.username}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // TEMPORAR – doar ca să nu fie gol
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _drafts[player.userId] = PlayerRatingDraft();
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save (temporary)"),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _submit() async {
    if (_drafts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No ratings to submit")),
      );
      return;
    }

    await PlayerRatingService.submitRatings(
      widget.matchId,
      _drafts,
    );

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ratings submitted")),
    );
  }
}


