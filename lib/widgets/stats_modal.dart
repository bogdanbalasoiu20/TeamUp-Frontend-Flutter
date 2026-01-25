import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/services/player_card_api.dart';
import 'package:team_up_fe_new/models/player_card_history.dart';
import 'package:team_up_fe_new/models/live_form.dart';
import 'package:team_up_fe_new/services/live_form_api.dart';
import 'package:team_up_fe_new/utils/live_form_state.dart';

const Color _bgDark = Color(0xFF091210);
const Color _cardSurface = Color(0xFF13241E);
const Color _accentGreen = Color(0xFF00E676);
const Color _textSecondary = Color(0xFF8A9E96);

class PlayerStatsModalContent extends StatefulWidget {
  final String userId;

  const PlayerStatsModalContent({
    super.key,
    required this.userId,
  });

  @override
  State<PlayerStatsModalContent> createState() =>
      _PlayerStatsModalContentState();
}

class _PlayerStatsModalContentState extends State<PlayerStatsModalContent> {
  bool _loadingHistory = true;
  List<PlayerCardHistoryPoint> _fullHistory = [];
  LiveForm? _liveForm;
  String _selectedAttribute = "Overall";

  final List<String> _statOptions = [
    "Overall",
    "PAC", "SHO", "PAS", "DRI", "DEF", "PHY"
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        PlayerCardService.getCardHistory(widget.userId),
        LiveFormApi.getLiveForm(widget.userId),
      ]);

      setState(() {
        _fullHistory = results[0] as List<PlayerCardHistoryPoint>;
        _liveForm = results[1] as LiveForm;
        _loadingHistory = false;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() => _loadingHistory = false);
    }
  }

  double _getValueForAttribute(PlayerCardHistoryPoint point, String attribute) {
    switch (attribute) {
      case "Overall": return point.overallRating;
      case "PAC": return point.pace ?? 0;
      case "SHO": return point.shooting ?? 0;
      case "PAS": return point.passing ?? 0;
      case "DRI": return point.dribbling ?? 0;
      case "DEF": return point.defending ?? 0;
      case "PHY": return point.physical ?? 0;
      default: return 0;
    }
  }

  List<FlSpot> _generateSpots() {
    List<FlSpot> spots = [];
    int count = _fullHistory.length;
    int startIndex = count > 10 ? count - 10 : 0;
    int xIndex = 0;

    for (int i = startIndex; i < count; i++) {
      final point = _fullHistory[i];
      final val = _getValueForAttribute(point, _selectedAttribute);
      spots.add(FlSpot(xIndex.toDouble(), val));
      xIndex++;
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: [
                _buildAttributesTab(),
                _buildEvolutionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Player Statistics",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TabBar(
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: _textSecondary,
            labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            indicator: const UnderlineTabIndicator(borderSide: BorderSide(width: 3, color: _accentGreen)),
            tabs: const [Tab(text: "ATTRIBUTES"), Tab(text: "EVOLUTION")],
          ),
          Container(height: 1, color: Colors.white12),
        ],
      ),
    );
  }

  Widget _buildAttributesTab() {
    if (_loadingHistory) return const Center(child: CircularProgressIndicator(color: _accentGreen));

    final gamesPlayed = _fullHistory.length;
    final baseRating = _fullHistory.isNotEmpty ? _fullHistory.last.overallRating : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_liveForm != null) ...[
            _buildLiveFormCard(_liveForm!, baseRating),
            const SizedBox(height: 24),
          ],

          const Text("General Info", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _statRow("Recorded Updates", "$gamesPlayed"),
          _statRow("Current Base Rating", baseRating > 0 ? "${baseRating.round()}" : "N/A"),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLiveFormCard(LiveForm form, double baseRating) {
    final state = getLiveFormState(form.delta);

    // Calculam si ROTUNJIM Live Rating-ul
    final double exactLiveRating = baseRating + form.delta;
    final int displayLiveRating = exactLiveRating.round();

    Color stateColor;
    IconData stateIcon;
    String stateText;

    switch (state) {
      case LiveFormState.onFire:
        stateColor = Colors.orangeAccent;
        stateIcon = Icons.local_fire_department_rounded;
        stateText = "ON FIRE";
        break;
      case LiveFormState.good:
        stateColor = _accentGreen;
        stateIcon = Icons.trending_up_rounded;
        stateText = "GOOD FORM";
        break;
      case LiveFormState.bad:
        stateColor = Colors.redAccent;
        stateIcon = Icons.trending_down_rounded;
        stateText = "BAD FORM";
        break;
      case LiveFormState.off:
        stateColor = Colors.blueGrey;
        stateIcon = Icons.ac_unit_rounded;
        stateText = "COLD";
        break;
      case LiveFormState.normal:
      default:
        stateColor = Colors.grey;
        stateIcon = Icons.remove_rounded;
        stateText = "NORMAL";
        break;
    }

    final isPositive = form.delta >= 0;
    final sign = isPositive ? "+" : "";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [stateColor.withOpacity(0.15), _cardSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stateColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(stateIcon, color: stateColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    stateText,
                    style: TextStyle(
                      color: stateColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Last ${form.matchesCount} matches",
                  style: TextStyle(color: _textSecondary, fontSize: 10),
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Live Rating", style: TextStyle(color: _textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "$displayLiveRating", // AICI AFISAM INTREGUL
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.0
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: stateColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: stateColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$sign${form.delta.toStringAsFixed(1)}",
                      style: TextStyle(
                        color: stateColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionTab() {
    final spots = _generateSpots();
    final currentVal = spots.isNotEmpty ? spots.last.y.round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Metric", style: TextStyle(color: _textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _cardSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedAttribute,
                        dropdownColor: _cardSurface,
                        icon: const Icon(Icons.arrow_drop_down, color: _accentGreen),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        items: _statOptions.map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) setState(() => _selectedAttribute = newValue);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Current", style: TextStyle(color: _textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    "$currentVal",
                    style: const TextStyle(color: _accentGreen, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 20),

          Container(
            height: 270,
            padding: const EdgeInsets.only(right: 12, left: 0, top: 24, bottom: 0),
            decoration: BoxDecoration(
              color: _cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator(color: _accentGreen))
                : spots.isEmpty
                ? Center(child: Text("No history available", style: TextStyle(color: _textSecondary)))
                : LineChart(_chartData(spots)),
          ),

          const SizedBox(height: 10),
          Center(
            child: Text(
              "Evolution over last ${spots.length} updates",
              style: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _chartData(List<FlSpot> spots) {
    if (spots.isEmpty) return LineChartData();

    double rawMinY = 100;
    double rawMaxY = 0;
    for (var s in spots) {
      if (s.y < rawMinY) rawMinY = s.y;
      if (s.y > rawMaxY) rawMaxY = s.y;
    }

    double minY = (rawMinY / 5).floor() * 5.0 - 5;
    double maxY = (rawMaxY / 5).ceil() * 5.0 + 5;

    minY = minY.clamp(0, 100);
    maxY = maxY.clamp(0, 100);

    if (maxY - minY < 10) {
      maxY = (minY + 10).clamp(0, 100);
      if (maxY - minY < 10) minY = (maxY - 10).clamp(0, 100);
    }

    const double interval = 5.0;

    return LineChartData(
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,

      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        checkToShowHorizontalLine: (value) => true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.08),
            strokeWidth: 1,
            dashArray: [4, 4],
          );
        },
      ),

      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  (value.toInt() + 1).toString(),
                  style: TextStyle(
                    color: _textSecondary.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              if (value == minY && value > 0) return const SizedBox.shrink();

              return Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),

      borderData: FlBorderData(show: false),

      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          color: _accentGreen,
          gradient: const LinearGradient(
            colors: [_accentGreen, Color(0xFF008C4A)],
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: _bgDark,
                strokeWidth: 2,
                strokeColor: _accentGreen,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                _accentGreen.withOpacity(0.2),
                _accentGreen.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],

      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: _cardSurface,
          tooltipRoundedRadius: 8,
          tooltipBorder: BorderSide(color: Colors.white.withOpacity(0.2)),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                "${spot.y.round()}",
                const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: _textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}