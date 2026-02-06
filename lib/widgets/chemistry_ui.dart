import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/chemistry_result.dart';
import 'package:team_up_fe_new/services/chemistry_api.dart';

class ChemistryUI extends StatefulWidget {
  final String otherUserId;

  const ChemistryUI({
    super.key,
    required this.otherUserId,
  });

  @override
  State<ChemistryUI> createState() => _ChemistryUIState();
}

class _ChemistryUIState extends State<ChemistryUI> {
  late Future<ChemistryResult> _chemistryFuture;

  @override
  void initState() {
    super.initState();
    _chemistryFuture = ChemistryApi.getChemistry(widget.otherUserId);
  }

  @override
  void didUpdateWidget(ChemistryUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.otherUserId != widget.otherUserId) {
      setState(() {
        _chemistryFuture = ChemistryApi.getChemistry(widget.otherUserId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChemistryResult>(
      future: _chemistryFuture,
      builder: (context, snapshot) {
        // 1. LOADING STATE
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        // 2. ERROR STATE (Aici era problema - acum o afișăm)
        if (snapshot.hasError) {
          debugPrint("CHEMISTRY ERROR: ${snapshot.error}"); // Scrie în consolă
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "Eroare: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 3. NO DATA STATE
        if (!snapshot.hasData) {
          return const Text("No data found", style: TextStyle(color: Colors.white));
        }

        // 4. SUCCESS STATE
        return _buildContent(context, snapshot.data!);
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.greenAccent),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ChemistryResult chemistry) {
    final score = chemistry.score;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13241E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 8),
              const Text(
                "FIELD CHEMISTRY",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "$score%",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _scoreColor(score),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getVerdict(score),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (chemistry.reasons.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chemistry.reasons
                  .take(3)
                  .map((r) => _buildReasonChip(r))
                  .toList(),
            )
          else
            const Text("Not enough data yet", style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  String _getVerdict(int score) {
    if (score >= 85) return "Perfect Match";
    if (score >= 70) return "Great Duo";
    if (score >= 50) return "Balanced";
    return "Low Synergy";
  }

  Widget _buildReasonChip(String text) {
    final isPositive = !text.toLowerCase().contains("no ") &&
        !text.toLowerCase().contains("diff") &&
        !text.toLowerCase().contains("low");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPositive
            ? const Color(0xFF00E676).withOpacity(0.1)
            : const Color(0xFFCF6679).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositive
              ? const Color(0xFF00E676).withOpacity(0.3)
              : const Color(0xFFCF6679).withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isPositive ? const Color(0xFF00E676) : const Color(0xFFCF6679),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 75) return const Color(0xFF00E676);
    if (score >= 50) return Colors.orangeAccent;
    return const Color(0xFFCF6679);
  }
}