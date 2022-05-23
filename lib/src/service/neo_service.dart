import 'package:neo4dart/src/cypher_executor.dart';
import 'package:neo4dart/src/enum/http_method.dart';
import 'package:neo4dart/src/model/node.dart';
import 'package:neo4dart/src/model/relationship.dart';
import 'package:neo4dart/src/neo4dart/neo_client.dart';
import 'package:neo4dart/src/node_util.dart';

class NeoService {
  late CypherExecutor _cypherExecutor;

  NeoService(NeoClient neoClient) {
    _cypherExecutor = CypherExecutor(neoClient);
  }

  Future<void> deleteAllNode() async {
    await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH (n) DETACH DELETE n',
    );
  }

  Future<List<Relationship>> findRelationshipById(int id) async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(a)-[r]->(b) WHERE id(r) = $id RETURN startNode(r), r, endNode(r)',
    );

    return EntityUtil.convertResponseToRelationship(result);
  }

  Future<List<Node>> findAllNodes() async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n) RETURN(n)',
    );
    return EntityUtil.convertResponseToNodeList(result);
  }

  Future<List<Node>> findAllNodesByLabel(String label) async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n:$label) RETURN(n)',
    );
    return EntityUtil.convertResponseToNodeList(result);
  }
}
