class Node {
  int? id;
  late String? name;
  List<String>? label = [];
  Map<String, dynamic> properties = {};

  Node.empty();
  Node.withId({required this.id, this.name, this.label, required this.properties});
  Node.withoutId({this.name, this.label, required this.properties});
}
