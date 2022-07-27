/// Row property
class Row {
  Map<String, dynamic> properties = {};

  /// Constructs row from json
  Row.fromJson(Map<String, dynamic> json) {
    for (final entry in json.entries) {
      properties[entry.key] = entry.value;
    }
  }
}
