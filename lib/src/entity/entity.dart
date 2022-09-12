import 'meta.dart';
import 'row.dart';

/// Representation of Neo4J node
class Entity {
  List<Row> rows = [];
  List<Meta> metas = [];
  List<String> labels = [];

  /// Construct entity from json
  Entity.fromJson(Map<String, dynamic> json) {
    final jsonRows = (json['row'] as List?);
    final jsonMetas = (json['meta']  as List?);

    if (jsonRows != null && jsonRows.isNotEmpty) {
      rows.add(Row.fromJson(jsonRows.first));

      if(jsonRows.length > 1){
        labels.addAll((jsonRows.last as List).map((e) => e.toString()).toList());
      }
    }
    if (jsonMetas != null) {
      for (var meta in jsonMetas) {
        if(meta != null){
          metas.add(Meta.fromJson(meta));
        }
      }
    }
  }
}