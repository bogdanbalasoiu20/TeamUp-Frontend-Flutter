class PageModel<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;

  PageModel({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
  });

  factory PageModel.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return PageModel(
      content: (json["content"] as List)
          .map((e) => fromJsonT(e))
          .toList(),
      totalElements: json["totalElements"],
      totalPages: json["totalPages"],
      size: json["size"],
      number: json["number"],
    );
  }
}