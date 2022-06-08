class Node {
  int? id;
  List<String> label = [];
  Map<String, dynamic> properties = {};

  Node.empty();
  Node.withId({required this.id, this.label = const [], required this.properties});
  Node.withoutId({this.label = const [], required this.properties});
}
