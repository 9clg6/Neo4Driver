class PathPoint {
  late double latitude;
  late double longitude;

  PathPoint(Map<String, dynamic> map){
    latitude = map["latitude"] as double;
    longitude = map["longitude"] as double;
  }
}