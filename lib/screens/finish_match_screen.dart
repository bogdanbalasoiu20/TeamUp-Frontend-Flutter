import 'package:flutter/material.dart';
import 'package:team_up_fe_new/services/match_api.dart';
import 'package:team_up_fe_new/exceptions/api_exception.dart';

class FinishMatchScreen extends StatefulWidget {
  final String matchId;

  const FinishMatchScreen({super.key, required this.matchId});

  @override
  State<FinishMatchScreen> createState() => _FinishMatchScreenState();
}

class _FinishMatchScreenState extends State<FinishMatchScreen> {
  bool isLoading = false;

  Future<void> _finishMatch() async {
    setState(() => isLoading = true);

    try {
      await MatchApi.finishMatch(widget.matchId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Match finished successfully")),
      );

      Navigator.pop(context, true); // returnează success
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error.message)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finish match"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Confirm match completion",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Text(
              "After finishing the match, the rating period will open for 24 hours. "
                  "Players will be able to rate each other.",
              style: TextStyle(fontSize: 15),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _finishMatch,
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Finish match"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
