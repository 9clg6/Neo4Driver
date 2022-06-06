import 'package:neo4dart/src/model/node.dart';

class Relationship {
  late int identity;
  Map<String, dynamic> properties = {};

  Node startNode = Node.empty();
  Node endNode = Node.empty();

  Relationship({required this.startNode, required this.endNode, required this.properties});

  Relationship.fromJson(Map<String, dynamic> json) {
    for (final element in json.entries) {
      if (element.key == "meta") {
        startNode.id = (element.value as List).elementAt(0)["id"];
        identity = (element.value as List).elementAt(1)["id"];
        endNode.id = (element.value as List).elementAt(2)["id"];
      } else if (element.key == "row") {
        ((element.value as List).elementAt(1) as Map).forEach((key, value) {
          properties[key] = value;
        });
        startNode.properties = (element.value as List).elementAt(0);
        endNode.properties = (element.value as List).elementAt(2);
      }
    }
  }
}
