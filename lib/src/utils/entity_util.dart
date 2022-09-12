import 'dart:convert';

import 'package:http/http.dart' show Response;

import '../../neo4driver.dart';
import '../entity/entity.dart';
import '../entity/path.dart';

/// Util used to convert query execution response
class EntityUtil {
  /// Convert response into nodes list
  static List<Node> convertResponseToNodeList(Response response) {
    List<Entity> nodeEntityList = [];

    final json = response.body;
    final jsonResult = jsonDecode(json);
    final results = jsonResult["results"] as List;
    if (results.isNotEmpty) {
      final data = results.first["data"] as List;

      for (final element in data) {
        nodeEntityList.add(Entity.fromJson(element));
      }

      return nodeEntityList
          .map(
            (e) => Node.withId(
              id: e.metas.first.id,
              labels: e.labels,
              properties: e.rows.first.properties,
            ),
          )
          .toList();
    } else {
      return [];
    }
  }

  /// Convert response into path (from shortest path algorithm)
  static Path convertResponseToPath(Response response) {
    final jsonResult = jsonDecode(response.body);
    final data = jsonResult["results"].first["data"] as List;

    if (data.isEmpty) return Path.fromList([]);
    return Path.fromList(data.first["row"].first);
  }

  /// Convert response into nodes boolean
  static bool convertResponseToBoolean(Response response) {
    final jsonResult = jsonDecode(response.body);
    final data = jsonResult["results"].first["data"] as List;
    if (data.isNotEmpty) {
      return data.first["row"].first as bool;
    }
    return false;
  }

  /// Convert response into relationships list
  static List<Relationship> convertResponseToRelationshipList(Response response) {
    List<Relationship> relationshipList = [];

    final jsonResult = jsonDecode(response.body);
    final results = jsonResult["results"] as List;

    if (results.isNotEmpty) {
      final data = results.first["data"] as List;

      if (data.isNotEmpty) {
        for (final element in data) {
          relationshipList.add(Relationship.fromNeo4jJson(element));
        }
      }

      return relationshipList;
    } else {
      return [];
    }
  }

  /// Convert response into double
  static Future<double> convertResponseToDouble(Response response) async {
    final jsonResult = jsonDecode(response.body);
    final result = jsonResult["results"].first["data"].first["row"].first as double;
    return result;
  }
}
