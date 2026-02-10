import 'package:flutter/material.dart';
import 'package:team_up_fe_new/models/chemistry_result.dart';
import 'package:team_up_fe_new/models/chemistry_reason.dart';
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
    _loadChemistry();
  }

  @override
  void didUpdateWidget(ChemistryUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.otherUserId != widget.otherUserId) {
      _loadChemistry();
    }
  }

  void _loadChemistry() {
    setState(() {
      _chemistryFuture = ChemistryApi.getChemistry(widget.otherUserId);
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChemistryResult>(
      future: _chemistryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return _buildCard(snapshot.data!);
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
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.greenAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ChemistryResult chemistry) {
    final score = chemistry.score;
    final color = _scoreColor(score);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutQuart,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF13241E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isExpanded
                  ? color.withOpacity(0.5)
                  : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: _isExpanded
                ? [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(score, color),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const SizedBox(height: 24),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    const SizedBox(height: 20),

                    _buildRoleMatchup(chemistry.yourRole, chemistry.otherRole),

                    const SizedBox(height: 24),

                    _buildReasons(chemistry),
                  ],
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

  Widget _buildHeader(int score, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Circular Progress Score
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 4,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  "$score",
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_graph_rounded, color: color, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "FIELD CHEMISTRY",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getVerdict(score),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Sageata animata
        AnimatedRotation(
          turns: _isExpanded ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleMatchup(String myRole, String otherRole) {
    String formatRole(String role) {
      if (role.isEmpty) return "Unknown";
      return role.replaceAll('_', ' ').split(' ').map((word) {
        if (word.isEmpty) return '';
        return word[0] + word.substring(1).toLowerCase();
      }).join(' ');
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildRoleColumn("You", formatRole(myRole), true),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.compare_arrows_rounded, color: Colors.white54, size: 20),
          ),

          _buildRoleColumn("Partner", formatRole(otherRole), false),
        ],
      ),
    );
  }

  Widget _buildRoleColumn(String label, String role, bool isMe) {
    final accentColor = const Color(0xFF00E676);

    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isMe ? accentColor : Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isMe
                ? accentColor.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isMe
                  ? accentColor.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            role,
            style: TextStyle(
              color: isMe ? accentColor : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasons(ChemistryResult chemistry) {
    if (chemistry.reasons.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "MATCH ANALYSIS",
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ),
      const SizedBox(height: 12),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: chemistry.reasons.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _buildReasonChip(chemistry.reasons[index]);
        },
      ),
    ]);
  }

  Widget _buildReasonChip(ChemistryReason reason) {
    Color color;
    IconData icon;

    switch (reason.type) {
      case 'POSITIVE':
        color = const Color(0xFF00E676);
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'NEGATIVE':
        color = const Color(0xFFCF6679);
        icon = Icons.remove_circle_outline_rounded;
        break;
      default:
        color = Colors.orangeAccent;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reason.message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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

  Color _scoreColor(int score) {
    if (score >= 75) return const Color(0xFF00E676);
    if (score >= 50) return Colors.orangeAccent;
    return const Color(0xFFCF6679);
  }
}