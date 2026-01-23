import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../../services/map_api.dart';
import '../../models/venue.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final mapController = MapController();
  List<Venue> venues = [];
  Venue? selectedVenue;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    final data = await MapApi.fetchBBox(
      44.35, 25.95, 44.55, 26.25,
    );

    setState(() {
      venues = data.map((e) => Venue.fromJson(e)).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final markers = venues
        .where((v) => v.latitude != null && v.longitude != null)
        .map((v) {
      return Marker(
        width: 40,
        height: 40,
        point: LatLng(v.latitude!, v.longitude!),
        builder: (ctx) => GestureDetector(
          onTap: () => setState(() => selectedVenue = v),
          child: Icon(
            Icons.location_on,
            color: (selectedVenue?.id == v.id) ? Colors.green : Colors.red,
            size: 40,
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Select field")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(44.4268, 26.1025),
              zoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "teamup",
              ),

              // Cluster layer
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  markers: markers,
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  builder: (context, cluster) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          cluster.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          if (selectedVenue != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _venueBottomSheet(selectedVenue!),
            ),

          if (loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _venueBottomSheet(Venue v) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            v.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          if (v.address != null) Text(v.address!),
          const SizedBox(height: 4),

          if (v.city != null) Text("City: ${v.city}"),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, v);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Select this field"),
            ),
          ),
        ],
      ),
    );
  }
}
