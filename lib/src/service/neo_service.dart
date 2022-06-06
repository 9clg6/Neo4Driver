import 'package:http/http.dart';
import 'package:neo4dart/src/exception/no_param_node_exception.dart';
import 'package:neo4dart/src/utils/cypher_executor.dart';
import 'package:neo4dart/src/enum/http_method.dart';
import 'package:neo4dart/src/model/node.dart';
import 'package:neo4dart/src/model/relationship.dart';
import 'package:neo4dart/src/neo4dart/neo_client.dart';
import 'package:neo4dart/src/utils/entity_util.dart';
import 'package:neo4dart/src/utils/string_util.dart';

class NeoService {
  late CypherExecutor _cypherExecutor;

  /// Constructs NeoService with NeoClient
  NeoService(NeoClient neoClient) {
    _cypherExecutor = CypherExecutor(neoClient);
  }

  Future<Relationship> createRelationship(
    int startNodeId,
    int endNodeId,
    String relationName,
    Map<String, dynamic> properties,
  ) async {
    for (final pair in properties.entries) {
      properties[pair.key] = "\"${pair.value}\"";
    }
    final query =
        'MATCH(a),(b) WHERE id(a) = $startNodeId AND id(b) = $endNodeId CREATE (a)-[r:$relationName $properties]->(b) RETURN startNode(r), r, endNode(r)';

    final response = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: query,
    );

    return EntityUtil.convertResponseToRelationshipList(response).first;
  }

  Future<Node?> createNodeWithNodeParam(Node node) async {
    return createNode(labels: node.label, properties: node.properties);
  }

  Future<Node?> createNode({List<String>? labels, required Map<String, dynamic> properties}) async {
    late Response response;
    String labelsString = "";

    if (labels != null && labels.isNotEmpty) {
      labelsString = StringUtil.buildLabelString(labels);
    }

    if (properties.isNotEmpty) {
      response = await _createNodeWithPropertiesLabelsName(properties, labelsString);
    } else {
      throw NoParamNodeException(cause: "Trying to create node without properties");
    }

    return EntityUtil.convertResponseToNodeList(response).first;
  }

  Future<Response> _createNodeWithPropertiesLabelsName(
    Map<String, dynamic> properties,
    String label,
  ) async {
    for (final pair in properties.entries) {
      properties[pair.key] = "\"${pair.value}\"";
    }
    return await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: label != ""
          ? 'CREATE (n:$label $properties) RETURN n, labels(n)'
          : 'CREATE (n $properties) RETURN n, labels(n)',
    );
  }

  /// Deletes all nodes in the database.
  /// /!\ Transaction commits at submission.
  Future<void> deleteAllNode() async {
    await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH (n) DETACH DELETE n',
    );
  }

  Future<void> deleteNodeById(int id) async {
    await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n) WHERE id(n)=$id DETACH DELETE n',
    );
  }

  Future<Relationship?> findRelationshipById(int id) async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(a)-[r]->(b) WHERE id(r) = $id RETURN startNode(r), r, endNode(r)',
    );
    return EntityUtil.convertResponseToRelationshipList(result).first;
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

  Future<Node?> findNodeById(int id) async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n) WHERE id(n)=$id RETURN n, labels(n)',
    );

    return EntityUtil.convertResponseToNodeList(result).first;
  }
}
