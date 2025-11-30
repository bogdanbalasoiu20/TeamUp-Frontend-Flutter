import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venue.dart';

class VenueApi {
  static const baseUrl = "https://teamup-backend-omi4.onrender.com/api/venues";

  static Future<List<Venue>> searchMap(String query) async {
    final uri = Uri.parse(
        "$baseUrl/search-map?q=$query&activeOnly=true&limit=50"
    );

    final response = await http.get(uri);

    final json = jsonDecode(response.body);

    final list = json["data"] as List;

    return list.map((e) => Venue.fromJson(e)).toList();
  }
}
