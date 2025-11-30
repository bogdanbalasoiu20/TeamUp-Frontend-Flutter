import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/venue.dart';

class MiniMapWidget extends StatelessWidget {
  final Venue? selectedVenue;
  final VoidCallback onTap;

  const MiniMapWidget({
    super.key,
    required this.onTap,
    required this.selectedVenue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // MAPĂ PASIVĂ
              IgnorePointer(
                ignoring: true,
                child: FlutterMap(
                  options: MapOptions(
                    center: selectedVenue != null
                        ? LatLng(
                      selectedVenue!.latitude!,
                      selectedVenue!.longitude!,
                    )
                        :  LatLng(44.4268, 26.1025),
                    zoom: selectedVenue != null ? 15 : 11,
                    interactiveFlags: InteractiveFlag.none,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "teamup",
                    ),

                    if (selectedVenue != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              selectedVenue!.latitude!,
                              selectedVenue!.longitude!,
                            ),
                            width: 50,
                            height: 50,
                            builder: (_) => Column(
                              children: const [
                                Icon(
                                  Icons.location_on,
                                  size: 42,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              ),

              // GRADIENT TOP
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // GRADIENT BOTTOM + TEXT
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // CENTERED INFO TEXT
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const Text(
                      "Tap to choose field",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.open_in_full_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),

              // RIPPLE EFFECT (vizual feedback)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: 0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
