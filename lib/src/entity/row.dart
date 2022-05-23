class Row {
  Map<String, dynamic> properties = {};

  Row.fromJson(Map<String, dynamic> json) {
    for (final entry in json.entries) {
      properties[entry.key] = entry.value;
    }
  }
}
