/// Main structure of API response
///
/// Backend sends something like this
///
/// {
///   "success": true/false,
///   "data": {...},
///   "error": {...}
/// }
///
/// This class allows the generic parsing for every T type

import 'package:team_up_fe_new/exceptions/api_error.dart';

class ApiResponse<T>{
  final bool success;
  final T? data;
  final ApiError? error;

  ApiResponse({required this.success, required this.data, required this.error});

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      success: json["success"] ?? false,
      data: json["data"] != null ? fromJsonT(json["data"]) : null,
      error: json["error"] != null ? ApiError.fromJson(json["error"]) : null,
    );
  }
}