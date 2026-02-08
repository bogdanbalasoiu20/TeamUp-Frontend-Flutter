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
  bool _isExpanded = false;

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
        _isExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChemistryResult>(
      future: _chemistryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return _buildContent(context, snapshot.data!);
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent)
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ChemistryResult chemistry) {
    final score = chemistry.score;
    final color = _scoreColor(score);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF13241E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _isExpanded ? color.withOpacity(0.5) : Colors.white.withOpacity(0.05),
                width: 1
            ),
            boxShadow: _isExpanded ? [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Label + Score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_graph_rounded, color: color, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            "FIELD CHEMISTRY",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$score%",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: color,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _getVerdict(score),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Right side: Animated Arrow
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70,
                          size: 20
                      ),
                    ),
                  ),
                ],
              ),

              // EXPANDABLE CONTENT (Reasons)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: Colors.white.withOpacity(0.1), height: 1),
                      const SizedBox(height: 16),
                      const Text(
                        "MATCH ANALYSIS",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (chemistry.reasons.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: chemistry.reasons
                              .map((r) => _buildReasonChip(r))
                              .toList(),
                        )
                      else
                        const Text(
                            "Calculated based on position and playstyle.",
                            style: TextStyle(color: Colors.white38, fontSize: 13)
                        ),
                    ],
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
                sizeCurve: Curves.easeInOutQuart,
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPositive
            ? const Color(0xFF00E676).withOpacity(0.08)
            : const Color(0xFFCF6679).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPositive
              ? const Color(0xFF00E676).withOpacity(0.2)
              : const Color(0xFFCF6679).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.check_circle_outline_rounded : Icons.remove_circle_outline_rounded,
            size: 14,
            color: isPositive ? const Color(0xFF00E676) : const Color(0xFFCF6679),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isPositive ? const Color(0xFF00E676) : const Color(0xFFCF6679),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 75) return const Color(0xFF00E676);
    if (score >= 50) return Colors.orangeAccent;
    return const Color(0xFFCF6679);
  }
}