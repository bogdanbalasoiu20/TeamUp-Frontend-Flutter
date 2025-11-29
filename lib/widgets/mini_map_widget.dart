import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/venue.dart';
import '../services/map_api.dart';
import '../screens/map_page.dart';

class MiniMapWidget extends StatefulWidget {
  const MiniMapWidget({super.key});

  @override
  State<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends State<MiniMapWidget> {
  List<Venue> venues = [];   //lista terenurilor incarcate de backend
  bool loading = true;  //indicator de incarcare pana vin datele

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  //incarc terenurile din backend folosind bounding box-ul bucurestiului(momentan hardcodat)
  Future<void> _loadVenues() async {
    final data = await MapApi.fetchBBox(
      44.35, 25.95, 44.55, 26.25,
    );

    setState(() {
      venues = data.map((e) => Venue.fromJson(e)).toList();
      loading = false;   //dupa ce datele se incarca ascund loading
    });
  }

  //construiesc o mini-harta, lipsita de interactiune, doar vizualizare
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(
                interactiveFlags: InteractiveFlag.none,   //dezactivare zoom
                center: LatLng(44.4268, 26.1025),  //centram pe bucuresti
                zoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "teamup",
                ),


                //marker-ele terenurilor afisate fara clustering
                MarkerLayer(
                  markers: venues.map((v) {
                    return Marker(
                      point: LatLng(v.latitude!, v.longitude!),
                      width: 30,
                      height: 30,
                      builder: (context) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 26,
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),

          // buton full-screen
          Positioned(
            right: 8,
            bottom: 8,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapPage()),
                );
              },
              child: const Text("Full Screen"),
            ),
          ),


          //indicator pentru loading(incacarea terenurilor)
          if (loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
