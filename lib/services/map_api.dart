import 'dart:convert';
import 'package:http/http.dart' as http;

class MapApi {
  static const String base = "https://teamup-backend-kx26.onrender.com";

  static Future<List<dynamic>> fetchBBox(
      double minLat, double minLng, double maxLat, double maxLng) async {

    final url = Uri.parse(
        "$base/api/venues/nearby-bbox"
            "?minLat=$minLat"
            "&minLng=$minLng"
            "&maxLat=$maxLat"
            "&maxLng=$maxLng"
            "&limit=300"
    );

    final res = await http.get(url);

    final jsonBody = jsonDecode(res.body);

    return jsonBody["data"] ?? [];
  }
}
