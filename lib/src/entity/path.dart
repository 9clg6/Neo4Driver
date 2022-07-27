import 'package:neo4dart/src/entity/path_point.dart';

/// Result of Shortest Path algorithm
class Path {
  List<PathPoint> path = [];

  /// Constructs path from List of dynamics
  Path.fromList(List<dynamic> pointsList){
    for (final element in pointsList) {
      path.add(PathPoint(element));
    }
  }
}