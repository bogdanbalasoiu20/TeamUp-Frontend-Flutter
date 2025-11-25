import 'api_error.dart';

class ApiException implements Exception {
final ApiError error;   // complet error fro  backend

ApiException(this.error);

/// The error is converted in a easier reading mode
@override
String toString() {
  if (error.details.isNotEmpty) {
    return error.details
        .map((e) => "${e.message}")
        .join("\n");
  }

  return error.message;
}
}