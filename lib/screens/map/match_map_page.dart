import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:team_up_fe_new/screens/notifications/notifications_page.dart';
import 'package:team_up_fe_new/services/notifications_api.dart';
import 'package:team_up_fe_new/widgets/left_menu_modal.dart';
import 'package:team_up_fe_new/widgets/navbar.dart';
import 'package:team_up_fe_new/widgets/top_bar.dart';
import '../../utils/app_colors.dart';
import '../../services/match_api.dart';
import '../../widgets/match_card_pin_widget.dart';
import '../matches/create_match_page.dart';
import 'package:team_up_fe_new/models/match.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MatchesMapPage extends StatefulWidget {
  const MatchesMapPage({super.key});

  @override
  State<MatchesMapPage> createState() => _MatchesMapPageState();
}

class _MatchesMapPageState extends State<MatchesMapPage> {
  final MapController mapController = MapController();

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

    final results = await MatchApi.fetchPins(
      minLat: 44.35,
      minLng: 25.95,
      maxLat: 44.55,
      maxLng: 26.25,
    );

    setState(() {
      pins = results;
      loading = false;
    });
  }

  Future<void> _loadUnseen() async {
    try {
      final all = await NotificationsApi.fetchAll();
      final count = all.where((n) => !n.isSeen).length;
      setState(() => unseenCount = count);
    } catch (_) {}
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
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.25,
          maxChildSize: 0.55,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.all(16),
                      itemCount: clusterMatches.length,
                      itemBuilder: (_, i) {
                        final match = clusterMatches[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _selectPin(match);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: MatchCardPin(match: match),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _selectPin(MatchPin pin) {
    setState(() => selectedPin = pin);

    mapController.move(
      LatLng(pin.latitude, pin.longitude),
      16,
    );
    mapController.rotate(0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [

          // ===================== MAIN CONTENT =====================
          NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: RefreshIndicator(
              onRefresh: _fetchMatchesOnInit,
              color: Colors.green,
              backgroundColor: Colors.white,

              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Stack(
                      children: [

                        // ------------------ BACKGROUND GRADIENT ------------------
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF003B2F),
                                AppColors.primaryGreenDark,
                                AppColors.primaryGreenLight,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),

                        // ------------------ TOP BAR ------------------
                        TopSheetBar(
                          unseenCount: unseenCount,
                          onNotificationsTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsPage(),
                              ),
                            );
                            _loadUnseen();
                          },
                          onMenuTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final loggedUser = prefs.getString("username");

                            if (loggedUser != null) {
                              showLeftMenuModal(context, loggedUser);
                            }
                          },
                        ),

                        // ------------------ HEADER TEXT ------------------
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 125, 28, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Browse Matches",
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 14,
                                      color: Colors.black54,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Find & join matches near you",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ------------------ WHITE SHEET ------------------
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.32,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 25,
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, -3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [

                                // ------------------ MAP ------------------
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: SizedBox(
                                    height:
                                    MediaQuery.of(context).size.height * 0.42,
                                    child: FlutterMap(
                                      mapController: mapController,
                                      options: MapOptions(
                                        center: LatLng(44.4268, 26.1025),
                                        zoom: 12,
                                        keepAlive: true,
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                          userAgentPackageName: "teamup",
                                        ),
                                        MarkerClusterLayerWidget(
                                          options: MarkerClusterLayerOptions(
                                            markers: pins.map(
                                                  (m) => Marker(
                                                key: ValueKey(m.id),
                                                width: 42,
                                                height: 42,
                                                point: LatLng(
                                                    m.latitude, m.longitude),
                                                builder: (_) => GestureDetector(
                                                  onTap: () => _selectPin(m),
                                                  child: Icon(
                                                    Icons.sports_soccer,
                                                    size: 38,
                                                    color: selectedPin?.id == m.id
                                                        ? Colors.red
                                                        : Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ).toList(),
                                            maxClusterRadius: 45,
                                            disableClusteringAtZoom: 16,
                                            onClusterTap: (cluster) =>
                                                _openClusterModal(
                                                    cluster.markers),
                                            builder: (context, cluster) =>
                                                CircleAvatar(
                                                  backgroundColor:
                                                  Colors.green.shade700,
                                                  child: Text(
                                                    cluster.length.toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // ------------------ LOCATION + NEW MATCH ------------------
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(
                                            Icons.location_on,
                                            color: Color(0xFF0A6F4A),
                                            size: 26,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Bucharest",
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final created = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const CreateMatchPage(),
                                            ),
                                          );

                                          if (created == true) {
                                            await _fetchMatchesOnInit();
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF003B2F),
                                                Color(0xFF0A6F4A),
                                                Color(0xFF46C264),
                                              ],
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(14),
                                          ),
                                          child: const Text(
                                            "New Match",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===================== PIN DETAILS OVERLAY =====================
          if (selectedPin != null)
            NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if (notification.extent <= 0.28) {
                  Future.microtask(() {
                    if (mounted) {
                      setState(() => selectedPin = null);
                    }
                  });
                }
                return true;
              },
              child: DraggableScrollableSheet(
                initialChildSize: 0.30,
                minChildSize: 0.25,
                maxChildSize: 0.55,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 18,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin:
                          const EdgeInsets.only(top: 8, bottom: 8),
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                            child: MatchCardPin(match: selectedPin!),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );

  }
}
