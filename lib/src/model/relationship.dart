import 'package:neo4dart/src/model/node.dart';

/// Code representation of Neo4J relationship
class Relationship {
  late int identity;
  Map<String, dynamic> properties = {};

  Node startNode = Node.empty();
  Node endNode = Node.empty();

  /// Constructs relationship with [startNode], [endNode] and [properties]
  Relationship({required this.startNode, required this.endNode, required this.properties});

  /// Constructs relationship from JSON
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

        startNode.label.addAll(((element.value as List).elementAt(3) as List).map((e) => e.toString()));
        endNode.label.addAll(((element.value as List).elementAt(4) as List).map((e) => e.toString()));
      }
    }
  }

  /// Convert current relationship into string json
  Map toJson() => {
    'identity': identity,
    'properties': properties,
    'startNode': startNode.toJson(),
    'endNode': endNode.toJson(),
  };
}
