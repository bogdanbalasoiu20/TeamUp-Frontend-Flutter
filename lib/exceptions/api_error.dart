/// "error" objects structure sent by backend
/// Backend send JSON like this:
///
/// "error": {
///   "code": "VALIDATION_ERROR",
///   "message": "Not valid data",
///   "details": [ {field,message}, ... ]
/// }
///
/// This class parses the object

import 'field_error.dart';

class ApiError{
  final String code;
  final String message;
  final List<FieldError> details;

  ApiError({required this.code, required this.message, required this.details});

  factory ApiError.fromJson(Map<String, dynamic> json){
    return ApiError(
      code:json["code"]??"",
      message:json["message"]??"",
      details: json["details"]!=null ? (json["details"] as List).map((e)=> FieldError.fromJson(e)).toList() : []
    );
  }
}