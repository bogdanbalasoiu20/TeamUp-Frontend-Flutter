import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'api_error.dart';
import 'package:shared_preferences/shared_preferences.dart';


///api layer over http.post/get etc
///sends responses to backend and throws ApiExceptions when the server responses with success=false
class ApiService {
  static const String baseUrl = "https://teamup-backend-omi4.onrender.com";

  /// POST generic
  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final url = Uri.parse("$baseUrl$path");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (decoded["error"] != null) {
      throw ApiException(ApiError.fromJson(decoded["error"]));
    }

    print("### RAW BACKEND RESPONSE:");
    print(response.body);

    throw ApiException(ApiError(
        code: "UNKNOWN", message: "Unknown error", details: []));
  }



  static Future<Map<String, dynamic>> get(String fullUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final url = Uri.parse(fullUrl);

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    if (data["error"] != null) {
      throw ApiException(ApiError.fromJson(data["error"]));
    }

    throw ApiException(ApiError(
        code: "UNKNOWN", message: "Unknown error", details: []));
  }

  static Future<dynamic> delete(String path) async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final url = Uri.parse("$baseUrl$path");

    final response = await http.delete(
      url,
      headers:{
        "Content-Type":"application/json",
        if(token!=null) "Authorization":"Bearer $token"
      }
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    if (data["error"] != null) {
      throw ApiException(ApiError.fromJson(data["error"]));
    }

    throw ApiException(ApiError(
        code: "UNKNOWN", message: "Unknown error", details: []));

  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final url = Uri.parse("$baseUrl$path");

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (decoded is Map && decoded["error"] != null) {
      throw ApiException(ApiError.fromJson(decoded["error"]));
    }

    print("### RAW BACKEND RESPONSE:");
    print(response.body);

    throw ApiException(ApiError(
      code: "UNKNOWN",
      message: "Unknown error",
      details: [],
    ));
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final url = Uri.parse("$baseUrl$path");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (decoded is Map && decoded["error"] != null) {
      throw ApiException(ApiError.fromJson(decoded["error"]));
    }

    print("### RAW BACKEND RESPONSE:");
    print(response.body);

    throw ApiException(ApiError(
      code: "UNKNOWN",
      message: "Unknown error",
      details: [],
    ));
  }


}
