class Venue {
  final String id;
  final String name;
  final String? address;
  final String? phoneNumber;

  // city eliminat total din JSON, se setează implicit București
  final String city = "bucuresti";

  final double? latitude;
  final double? longitude;

  final String osmType;
  final int? osmId;
  final Map<String, dynamic>? tagsJson;
  final String source;
  final bool isActive;

  Venue({
    required this.id,
    required this.name,
    this.address,
    this.phoneNumber,
    this.latitude,
    this.longitude,
    required this.osmType,
    this.osmId,
    this.tagsJson,
    required this.source,
    required this.isActive,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json["id"],
      name: json["name"] ?? "",
      address: json["address"],
      phoneNumber: json["phoneNumber"],
      // city ignorat complet
      latitude: json["latitude"]?.toDouble(),
      longitude: json["longitude"]?.toDouble(),
      osmType: json["osmType"] ?? "",
      osmId: json["osmId"],
      tagsJson: json["tagsJson"],
      source: json["source"] ?? "",
      isActive: json["isActive"] ?? true,
    );
  }
}
