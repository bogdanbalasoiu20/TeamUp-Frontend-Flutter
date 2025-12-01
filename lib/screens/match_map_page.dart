import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../services/match_api.dart';
import '../widgets/match_card_pin_widget.dart';

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


  void _openClusterModal(List<Marker> clusterMarkers) {
    final clusterMatches = clusterMarkers.map((marker) {
      final id = (marker.key as ValueKey).value;
      return pins.firstWhere((p) => p.id == id);
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 360,
          child: ListView.builder(
            itemCount: clusterMatches.length,
            itemBuilder: (_, i) {
              final match = clusterMatches[i];
              return ListTile(
                leading: const Icon(Icons.sports_soccer, color: Colors.green),
                title: Text(
                    match.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )
                ),
                subtitle: Text(match.startsAt),
                onTap: () {
                  Navigator.pop(context);
                  _selectPin(match);
                },
              );
            },
          ),
        );
      },
    );
  }

  // SELECT PIN
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
    final double cardHeight = 220;

    final markers = pins.map((m) {
      final bool isSelected = selectedPin?.id == m.id;

      return Marker(
        key: ValueKey(m.id),
        width: isSelected ? 54 : 42,
        height: isSelected ? 54 : 42,
        point: LatLng(m.latitude, m.longitude),
        builder: (_) => GestureDetector(
          onTap: () => _selectPin(m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.sports_soccer,
              color: isSelected ? Colors.blueAccent : Colors.green,
              size: isSelected ? 48 : 36,
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
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
                  markers: markers,
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  disableClusteringAtZoom: 16,
                  centerMarkerOnClick: false,
                  zoomToBoundsOnClick: false,

                  onClusterTap: (cluster) {
                    _openClusterModal(cluster.markers);
                  },

                  builder: (context, cluster) => CircleAvatar(
                    backgroundColor: Colors.green.shade700,
                    child: Text(
                      cluster.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),

          if (selectedPin != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: cardHeight,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => selectedPin = null),
                          child: const Icon(Icons.close, color: Colors.black45),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: MatchCardPin(match: selectedPin!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
