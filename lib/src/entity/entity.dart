import 'package:neo4dart/src/entity/meta.dart';
import 'package:neo4dart/src/entity/row.dart';

class Entity {
  List<Row> rows = [];
  List<Meta> metas = [];

  late Row row;
  late Meta meta;

  Entity({required this.row, required this.meta});

  Entity.fromJson(Map<String, dynamic> json) {
    if (json['row'] != null) {
      for (var row in (json['row'] as List)) {
        rows.add(Row.fromJson(row));
      }
    }
    if (json['meta'] != null) {
      for (var meta in (json['meta'] as List)) {
        metas.add(Meta.fromJson(meta));
      }
    }
  }
}