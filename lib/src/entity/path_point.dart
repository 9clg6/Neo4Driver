/// Point in path from shortest path algorithm
class PathPoint {
  late double latitude;
  late double longitude;

  /// Create point from json
  PathPoint(Map<String, dynamic> json) {
    latitude = json["latitude"] as double;
    longitude = json["longitude"] as double;
  }

  Map toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
