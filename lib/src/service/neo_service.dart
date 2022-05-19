import 'dart:convert';

import 'package:neo4dart/src/cypher_executor.dart';
import 'package:neo4dart/src/entity/node_entity.dart';
import 'package:neo4dart/src/enum/http_method.dart';
import 'package:neo4dart/src/model/node.dart';
import 'package:neo4dart/src/neo4dart/neo_client.dart';

class NeoService {
  late CypherExecutor _cypherExecutor;

  NeoService(NeoClient neoClient) {
    _cypherExecutor = CypherExecutor(neoClient);
  }

  Future<List<Node>> findAllNodes() async {
    List<NodeEntity> nodeEntityList = [];

    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n) RETURN(n)',
    );

    final jsonResult = jsonDecode(result.body);
    final data = jsonResult["results"].first["data"] as List;

    for (final element in data) {
      nodeEntityList.add(NodeEntity.fromJson(element));
    }

    return nodeEntityList.map((e) => Node(id: e.meta.id, attributes: e.row.attributes)).toList();
  }
}
