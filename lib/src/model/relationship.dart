import '../../neo4_driver.dart';

/// Code representation of Neo4J relationship
class Relationship {
  late int identity;
  Map<String, dynamic> properties = {};

  Node startNode = Node.empty();
  Node endNode = Node.empty();

  /// Constructs relationship with [startNode], [endNode] and [properties]
  Relationship({required this.startNode, required this.endNode, required this.properties});

  /// Constructs relationship from JSON
  Relationship.fromNeo4jJson(Map<String, dynamic> json) {
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

        startNode.labels.addAll(((element.value as List).elementAt(3) as List).map((e) => e.toString()));
        endNode.labels.addAll(((element.value as List).elementAt(4) as List).map((e) => e.toString()));
      }
    }
  }

  Relationship.fromJson(Map<String, dynamic> json) {
    identity = json["identity"];
    properties = json["properties"];
    startNode = Node.withId(
      id: json["startNode"]["identity"],
      properties: json["startNode"]["properties"],
      labels: (json["startNode"]["labels"] as List).map((e) => e.toString()).toList(),
    );
    endNode = Node.withId(
      id: json["startNode"]["identity"],
      properties: json["endNode"]["properties"],
      labels: (json["endNode"]["labels"] as List).map((e) => e.toString()).toList(),
    );
  }

  /// Convert current relationship into string json
  Map toJson() => {
        'identity': identity,
        'properties': properties,
        'startNode': startNode.toJson(),
        'endNode': endNode.toJson(),
      };
}
