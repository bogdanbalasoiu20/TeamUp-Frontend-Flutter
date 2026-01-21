import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/match_info.dart';
import 'package:team_up_fe_new/services/match_api.dart';
import 'package:team_up_fe_new/exceptions/api_exception.dart';

class FinishMatchScreen extends StatefulWidget {
  final MatchInfo match;

  const FinishMatchScreen({super.key, required this.match});

  @override
  State<FinishMatchScreen> createState() => _FinishMatchScreenState();
}

class _FinishMatchScreenState extends State<FinishMatchScreen> {
  bool isLoading = false;

  Future<void> _finishMatch() async {
    setState(() => isLoading = true);

    try {
      debugPrint("Finishing match ${widget.match.id}");

      await MatchApi.finishMatch(widget.match.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Match finished successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Finish match error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Finish failed")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;

    return Scaffold(
      appBar: AppBar(title: const Text("Finish match")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔍 DEBUG INFO
            Text("MATCH DEBUG", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            _row("Match ID", m.id),
            _row("Creator ID", m.creatorId),
            _row("Title", m.title),
            _row("Venue", m.venueName),
            _row("Address", m.venueAddress),
            _row("Status", m.status),
            _row("Starts at", m.startsAt.toString()),
            _row("Duration", "${m.durationMinutes} min"),
            _row("Players", "${m.currentPlayers}/${m.maxPlayers}"),

            const Divider(height: 32),

            const Text(
              "After finishing the match, the rating period will open for 24 hours.",
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _finishMatch,
                child: isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text("Finish match"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

