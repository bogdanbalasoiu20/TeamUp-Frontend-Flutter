import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../utils/app_colors.dart';
import '../services/match_api.dart';
import '../widgets/match_card_pin_widget.dart';
import '../screens/create_match_page.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchMatchesOnInit();
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


  // ------------------ Open cluster modal ------------------
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



  // ------------------ Select pin ------------------
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A6F4A),
        child: const Icon(Icons.add, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateMatchPage()),
          );
        },
      ),

      body: Stack(
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

          // ------------------ HEADER TEXT ------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 90, 28, 0),
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
            top: size.height * 0.28,
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

              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: LatLng(44.4268, 26.1025),
                    zoom: 12,
                    keepAlive: true,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "teamup",
                    ),

                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        markers: pins.map((m) {
                          final isSelected = m.id == selectedPin?.id;

                          return Marker(
                            key: ValueKey(m.id),
                            width: isSelected ? 54 : 42,
                            height: isSelected ? 54 : 42,
                            point: LatLng(m.latitude, m.longitude),
                            builder: (_) => GestureDetector(
                              onTap: () => _selectPin(m),
                              child: Icon(
                                Icons.sports_soccer,
                                size: isSelected ? 50 : 38,
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.green,
                              ),
                            ),
                          );
                        }).toList(),
                        maxClusterRadius: 45,
                        disableClusteringAtZoom: 16,

                        onClusterTap: (cluster) =>
                            _openClusterModal(cluster.markers),

                        builder: (context, cluster) => CircleAvatar(
                          backgroundColor: Colors.green.shade700,
                          child: Text(
                            cluster.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ------------------ PIN SELECTED CARD------------------

          if (selectedPin != null)
            NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if (notification.extent <= 0.28) {
                  Future.microtask(() {
                    if (mounted) {
                      setState(() {
                        selectedPin = null;
                      });
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
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: MatchCardPin(match: selectedPin!),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )


        ],
      ),
    );
  }
}
