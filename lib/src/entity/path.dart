import 'package:neo4_dart/src/entity/path_point.dart';

/// Result of Shortest Path algorithm
class Path {
  List<PathPoint> path = [];

  /// Constructs path from List of dynamics
  Path.fromList(List<dynamic> pointsList) {
    for (final element in pointsList) {
      path.add(PathPoint(element));
    }
  }

  Map toJson() {
    Map<String, dynamic> finalMap = {};
    for (final coordinates in path) {
      finalMap.putIfAbsent(path.indexOf(coordinates).toString(), () => {
        coordinates.latitude,
        coordinates.longitude
      });
    }
    return finalMap;
  }
}