import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'api_error.dart';


///api layer over http.post/get etc
///sends responses to backend and throws ApiExceptions when the server responses with success=false
class ApiService {
  static const String baseUrl = "https://teamup-backend-omi4.onrender.com";

  /// POST generic
  static Future<dynamic> post(
      String path,
      Map<String, dynamic> body,
      ) async {
    final url = Uri.parse("$baseUrl$path");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);

    //for status between 200 and 299 => success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    // if backend sends "error" object
    if (decoded["error"] != null) {
      throw ApiException(ApiError.fromJson(decoded["error"]));
    }

    // fallback for rare cases
    throw ApiException(
      ApiError(code: "UNKNOWN", message: "Unknown error", details: []),
    );
  }


  static Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
    });

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    // backend returns { success: false, error: {...} }
    if (data["error"] != null) {
      throw ApiException(ApiError.fromJson(data["error"]));
    }

    throw ApiException(
      ApiError(code: "UNKNOWN", message: "Unknown error", details: []),
    );
  }
}
