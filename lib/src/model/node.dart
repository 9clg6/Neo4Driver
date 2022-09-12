/// Code representation of Neo4J node
class Node {
  int? id;
  List<String> labels = [];
  Map<String, dynamic> properties = {};

  /// Constructs empty node
  Node.empty();

  /// Constructs node with [id], [labels] and [properties]
  Node.withId({required this.id, this.labels = const [], required this.properties});

  /// Constructs node without ID, [labels] (default value = empty) and [properties]
  Node.withoutId({this.labels = const [], required this.properties});

  /// Convert current node into string json
  Map toJson() => {
        'identity': id,
        'labels': labels,
        'properties': properties,
      };
}
