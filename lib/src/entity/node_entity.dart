class NodeEntity {
  late Row row;
  late Meta meta;

  NodeEntity({required this.row, required this.meta});

  NodeEntity.fromJson(Map<String, dynamic> json) {
    if (json['row'] != null) {
      row = Row.fromJson((json['row'] as List).first);
    }
    if (json['meta'] != null) {
      meta = Meta.fromJson((json['meta'] as List).first);
    }
  }
}

class Row {
  Map<String, dynamic> attributes = {};

  Row.fromJson(Map<String, dynamic> json) {
    for (final entry in json.entries) {
      attributes[entry.key] = entry.value;
    }
  }
}

class Meta {
  late int id;
  late String type;
  late bool deleted;

  Meta({required this.id,required this.type,required this.deleted});

  Meta.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    deleted = json['deleted'];
  }
}
