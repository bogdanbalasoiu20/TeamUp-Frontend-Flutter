import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../../services/map_api.dart';
import '../../models/venue.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

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
  Position? userPosition;
  bool _showLiveLocationText = false;

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _loadVenues();
  }

  Future<Position> _getUserLocation() async {
    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Location services are disabled");
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 2),
    );
  }

  Future<void> _loadUserLocation() async {
    try {
      final pos = await _getUserLocation();
      if (!mounted) return;

      mapController.move(
        LatLng(pos.latitude, pos.longitude),
        14,
      );

      setState(() {
        userPosition = pos;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
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
    final List<Marker> markers = venues
        .where((v) => v.latitude != null && v.longitude != null)
        .map((v) {
      final isSelected = selectedVenue?.id == v.id;
      return Marker(
        width: isSelected ? 65 : 55,
        height: isSelected ? 65 : 55,
        point: LatLng(v.latitude!, v.longitude!),
        builder: (ctx) => GestureDetector(
          onTap: () => setState(() => selectedVenue = v),
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: isSelected ? 65 : 55,
                  color: isSelected ? _accentGreen : _bgDark,
                ),
                if (!isSelected)
                  Positioned(
                    top: isSelected ? 12 : 10,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white12,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Positioned(
                  top: isSelected ? 14 : 12,
                  child: Icon(
                    Icons.sports_soccer,
                    size: isSelected ? 24 : 20,
                    color: isSelected ? _bgDark : _accentGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: _bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Select field",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _bgDark.withOpacity(0.85),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(44.4268, 26.1025),
              zoom: 12,
              maxZoom: 18,
              onTap: (_, __) => setState(() => selectedVenue = null),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "teamup",
                maxZoom: 18,
                maxNativeZoom: 18,
              ),

              if (userPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        userPosition!.latitude,
                        userPosition!.longitude,
                      ),
                      width: 120,
                      height: 80,
                      builder: (_) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _showLiveLocationText = !_showLiveLocationText;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_showLiveLocationText) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                    ]
                                ),
                                child: const Text(
                                  'Your Location',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
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

              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  markers: markers,
                  maxClusterRadius: 45,
                  size: const Size(45, 45),
                  builder: (context, cluster) {
                    return Container(
                      decoration: BoxDecoration(
                        color: _bgDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: _accentGreen, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
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

          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastLinearToSlowEaseIn,
            left: 16,
            right: 16,
            bottom: selectedVenue != null ? 20 : -250,
            child: selectedVenue == null
                ? const SizedBox.shrink()
                : _buildFloatingVenueCard(selectedVenue!),
          ),

          if (loading)
            Positioned.fill(
              child: Container(
                color: _bgDark.withOpacity(0.6),
                child: Center(
                  child: CircularProgressIndicator(color: _accentGreen),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingVenueCard(Venue v) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accentGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.stadium_rounded, color: _accentGreen, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      v.address ?? (v.city != null ? "City: ${v.city}" : "No address available"),
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => selectedVenue = null),
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context, v);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _accentGreen,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _accentGreen.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Select this field",
                        style: TextStyle(
                          color: _bgDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _openGoogleMaps(v),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _bgDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Icon(Icons.directions_outlined, color: _accentGreen, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps(Venue venue) async {
    final lat = venue.latitude;
    final lng = venue.longitude;
    if (lat == null || lng == null) return;

    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}