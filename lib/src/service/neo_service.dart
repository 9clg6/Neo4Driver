import 'package:neo4dart/src/cypher_executor.dart';
import 'package:neo4dart/src/enum/http_method.dart';
import 'package:neo4dart/src/model/node.dart';
import 'package:neo4dart/src/model/relationship.dart';
import 'package:neo4dart/src/neo4dart/neo_client.dart';
import 'package:neo4dart/src/node_util.dart';

class NeoService {
  late CypherExecutor _cypherExecutor;

  /// Constructs NeoService with NeoClient
  NeoService(NeoClient neoClient) {
    _cypherExecutor = CypherExecutor(neoClient);
  }

  Future<void> createNodeWithNodeParam(Node node) async {
    return createNode(node.properties["name"], node.label, node.properties);
  }

  Future<void> createNode(String name, List<String>? labels, Map<String, dynamic>? properties) async {
    String labelsString = "";
    if(labels != null && labels.isNotEmpty && properties != null && properties.isNotEmpty){
      properties.putIfAbsent("name", () => name);

      for (final pair in properties.entries) {
        properties[pair.key] = "\"${pair.value}\"";
      }

      if(labels.length > 1){
        for (int i=0 ; i<labels.length ; i++) {
          if(labels.elementAt(i) != labels.last){
            labelsString += "${labels.elementAt(i)},";
          } else {
            labelsString += labels.elementAt(i);
          }
        }
      } else {
        labelsString = labels.first;
      }


      final query = 'CREATE (n:$labelsString $properties)';

      await _cypherExecutor.executeQuery(
        method: HTTPMethod.post,
        query: query,
      );
    } else {

    }
  }

  /// Deletes all nodes in the database.
  /// /!\ Transaction commits at submission.
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
    return EntityUtil.convertResponseToRelationshipList(result);
  }

  Future<List<Node>> findAllNodes() async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n) RETURN n, labels(n)',
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

  Future<Node> findNodeById(int id) async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n) WHERE id(n)=$id RETURN n, labels(n)',
    );
    return EntityUtil.convertResponseToNodeList(result).first;
  }
}
