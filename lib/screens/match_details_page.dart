import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../services/match_participant_api.dart';

class MatchParticipantsPage extends StatefulWidget {
  final String matchId;

  const MatchParticipantsPage({super.key, required this.matchId});

  @override
  State<MatchParticipantsPage> createState() => _MatchParticipantsPageState();
}

class _MatchParticipantsPageState extends State<MatchParticipantsPage> {
  bool loading = true;
  List<Participant> participants = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await MatchParticipantApi.fetchParticipants(widget.matchId);

    setState(() {
      participants = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Participants")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final accepted = participants.where((p) => p.status == "ACCEPTED").toList();
    final requested = participants.where((p) => p.status == "REQUESTED").toList();
    final invited = participants.where((p) => p.status == "INVITED").toList();
    final waitlist = participants.where((p) => p.status == "WAITLIST").toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Match Participants"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section("Players", accepted),
          _section("Requests", requested),
          _section("Invited", invited),
          _section("Waitlist", waitlist),
        ],
      ),
    );
  }

  Widget _section(String title, List<Participant> list) {
    if (list.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...list.map((p) => _participantTile(p)),
        ],
      ),
    );
  }

  Widget _participantTile(Participant p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF003B2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              p.username.substring(0, 1).toUpperCase(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              p.username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              p.status,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
