import 'package:neo4dart/src/entity/path_point.dart';

class Path {
  List<PathPoint> path = [];

  Path.fromList(List<dynamic> pointsList){
    for (final element in pointsList) {
      path.add(PathPoint(element));
    }
  }
}