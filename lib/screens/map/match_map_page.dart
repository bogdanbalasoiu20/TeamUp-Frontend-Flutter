import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/models/match.dart';
import 'package:team_up_fe_new/screens/matches/create_match_page.dart';
import 'package:team_up_fe_new/screens/notifications/notifications_page.dart';
import 'package:team_up_fe_new/services/match_api.dart';
import 'package:team_up_fe_new/services/notifications_api.dart';
import 'package:team_up_fe_new/widgets/left_menu_modal.dart';
import 'package:team_up_fe_new/widgets/match_card_pin_widget.dart';
import 'package:team_up_fe_new/widgets/top_bar.dart';

class MatchesMapPage extends StatefulWidget {
  const MatchesMapPage({super.key});

  @override
  State<MatchesMapPage> createState() => _MatchesMapPageState();
}

class _MatchesMapPageState extends State<MatchesMapPage> with TickerProviderStateMixin {
  final MapController mapController = MapController();

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);

  List<MatchPin> pins = [];
  MatchPin? selectedPin;
  bool loading = false;
  int unseenCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchMatchesOnInit();
    _loadUnseen();
  }

  Future<void> _fetchMatchesOnInit() async {
    setState(() => loading = true);
    try {
      final results = await MatchApi.fetchPins(
        minLat: 44.35, minLng: 25.95, maxLat: 44.55, maxLng: 26.25,
      );
      if (mounted) {
        setState(() {
          pins = results;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadUnseen() async {
    try {
      final all = await NotificationsApi.fetchAll();
      final count = all.where((n) => !n.isSeen).length;
      if (mounted) setState(() => unseenCount = count);
    } catch (_) {}
  }

  void _selectPin(MatchPin pin) {
    setState(() => selectedPin = pin);
    mapController.move(
      LatLng(pin.latitude - 0.005, pin.longitude),
      15,
    );
  }

  void _deselectPin() {
    setState(() => selectedPin = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          _buildMapLayer(),
          _buildTopInterface(),
          _buildRefreshButton(),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: selectedPin == null ? 30 : -100,
            left: 20,
            right: 20,
            child: _buildFloatingBottomBar(),
          ),
          _buildSelectedMatchCard(),
          if (loading && pins.isEmpty)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _bgDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: _accentGreen, strokeWidth: 2)),
                      const SizedBox(width: 10),
                      const Text("Updating map...", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapLayer() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: LatLng(44.4268, 26.1025),
        zoom: 13,
        minZoom: 5,
        maxZoom: 18,
        onTap: (_, __) => _deselectPin(),
        interactiveFlags: InteractiveFlag.all,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "teamup",
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(45, 45),
            markers: pins.map((m) => _buildMarker(m)).toList(),
            builder: (context, markers) {
              return Container(
                decoration: BoxDecoration(
                    color: _bgDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: _accentGreen, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                    ]
                ),
                child: Center(
                  child: Text(
                    markers.length.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            onClusterTap: (cluster) => _openClusterModal(cluster.markers),
          ),
        ),
      ],
    );
  }

  Marker _buildMarker(MatchPin m) {
    final isSelected = selectedPin?.id == m.id;
    return Marker(
      key: ValueKey(m.id),
      width: isSelected ? 60 : 50,
      height: isSelected ? 60 : 50,
      point: LatLng(m.latitude, m.longitude),
      builder: (_) => GestureDetector(
        onTap: () => _selectPin(m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? _accentGreen : _bgDark,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Icon(
            Icons.sports_soccer,
            size: isSelected ? 35 : 28,
            color: isSelected ? _bgDark : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTopInterface() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _bgDark.withOpacity(0.9),
              _bgDark.withOpacity(0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: TopSheetBar(
            unseenCount: unseenCount,
            onNotificationsTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
              _loadUnseen();
            },
            onMenuTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final user = prefs.getString("username");
              if (user != null && mounted) showLeftMenuModal(context, user);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _cardSurface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.my_location, color: _accentGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Browsing in",
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      const Text(
                        "Bucharest",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  final created = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateMatchPage()),
                  );
                  if (created == true) _fetchMatchesOnInit();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                      color: _accentGreen,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: _accentGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                  ),
                  child: const Text(
                    "+ Create",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMatchCard() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      bottom: selectedPin != null ? 0 : -400,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _deselectPin();
          }
        },
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            color: _cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: selectedPin == null
              ? const SizedBox.shrink()
              : Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: MatchCardPin(match: selectedPin!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openClusterModal(List<Marker> clusterMarkers) {
    final clusterMatches = clusterMarkers.map((marker) {
      final markerId = (marker.key as ValueKey).value;
      return pins.firstWhere((p) => p.id == markerId);
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: _bgDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text("${clusterMatches.length} Matches here", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: clusterMatches.length,
                  separatorBuilder: (_,__) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    final match = clusterMatches[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _selectPin(match);
                      },
                      child: MatchCardPin(match: match),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildRefreshButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 70,
      right: 20,
      child: GestureDetector(
        onTap: () {
          _fetchMatchesOnInit();
        },
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: _cardSurface,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: loading
              ? Padding(
            padding: const EdgeInsets.all(12.0),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _accentGreen,
            ),
          )
              : const Icon(
            Icons.refresh_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}