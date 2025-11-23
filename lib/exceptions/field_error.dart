///error for a body field
///Backend example:
///{
///   "field":"password",
///   "message":"size must be between 8 and 10"
///}

class FieldError{
  final String field; //invalid field
  final String message; //error message

  FieldError({required this.field, required this.message});

  factory FieldError.fromJson(Map<String, dynamic> json){
    return FieldError(field: json['field'] ?? '', message: json['message'] ?? '');
  }
}