/// Code representation of Neo4J node
class Node {
  int? id;
  List<String> label = [];
  Map<String, dynamic> properties = {};

  /// Constructs empty node
  Node.empty();

  /// Constructs node with [id], [label] and [properties]
  Node.withId({required this.id, this.label = const [], required this.properties});

  /// Constructs node without ID, [label] (default value = empty) and [properties]
  Node.withoutId({this.label = const [], required this.properties});

  /// Convert current node into string json
  Map toJson() => {
    'identity': id,
    'labels': label,
    'properties': properties,
  };
}
