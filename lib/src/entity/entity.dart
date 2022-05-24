import 'package:neo4dart/src/entity/meta.dart';
import 'package:neo4dart/src/entity/row.dart';

class Entity {
  List<Row> rows = [];
  List<Meta> metas = [];
  List<String> labels = [];

  Entity.fromJson(Map<String, dynamic> json) {
    final jsonRows = (json['row'] as List?);

    if (jsonRows != null) {
      rows.add(Row.fromJson(jsonRows.first));

      if(jsonRows.length > 1){
        labels.addAll((jsonRows.last as List).map((e) => e.toString()).toList());
      }
    }
    if (json['meta'] != null) {
      for (var meta in (json['meta'] as List)) {
        if(meta != null){
          metas.add(Meta.fromJson(meta));
        }
      }
    }
  }
}