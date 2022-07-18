import 'package:http/http.dart';
import 'package:neo4dart/src/exception/no_param_node_exception.dart';
import 'package:neo4dart/src/exception/not_enough_id_exception.dart';
import 'package:neo4dart/src/model/property_to_check.dart';
import 'package:neo4dart/src/utils/cypher_executor.dart';
import 'package:neo4dart/src/enum/http_method.dart';
import 'package:neo4dart/src/model/node.dart';
import 'package:neo4dart/src/model/relationship.dart';
import 'package:neo4dart/src/utils/entity_util.dart';
import 'package:neo4dart/src/utils/string_util.dart';

class NeoService {
  late CypherExecutor _cypherExecutor;

  /// Constructs NeoService with NeoClient
  NeoService(String databaseAddress) {
    _cypherExecutor = CypherExecutor(databaseAddress: databaseAddress);
  }

  NeoService.withHttpClient(Client client){
    _cypherExecutor = CypherExecutor.withHttpClient(httpClient: client);
  }

  /// Constructs NeoService with NeoClient
  NeoService.withAuthorization({
    required String username,
    required String password,
    String databaseAddress = 'http://localhost:7474/',
  }) {
    _cypherExecutor = CypherExecutor.withAuthorization(username, password, databaseAddress);
  }

  Future<List<Relationship>> createRelationshipFromNodeToNodes(
    int startNodeId,
    List<int> endNodesId,
    String relationName,
    Map<String, dynamic> properties,
  ) async {
    List<Future<Relationship>> relationShipList = [];

    if (endNodesId.length > 1) {
      Future.forEach(endNodesId, (nodeId) {
        relationShipList.add(createRelationship(startNodeId, nodeId as int, relationName, Map.from(properties)));
      });
    } else {
      throw NotEnoughIdException(cause: "Not enough id in Nodes's id list (mini 2)");
    }
    return Future.wait(relationShipList);
  }

  Future<Relationship> createRelationship(
    int startNodeId,
    int endNodeId,
    String relationName,
    Map<String, dynamic> properties,
  ) async {
    for (final pair in properties.entries) {
      if (pair.value is String) properties[pair.key] = "\"${pair.value}\"";
    }

    final query =
        'MATCH(a),(b) WHERE id(a) = $startNodeId AND id(b) = $endNodeId CREATE (a)-[r:$relationName $properties]->(b) RETURN startNode(r), r, endNode(r), labels(a), labels(b)';

    final response = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: query,
    );

    return EntityUtil.convertResponseToRelationshipList(response).first;
  }

  Future<Node?> createNodeWithNodeParam(Node node) async {
    return createNode(labels: node.label, properties: node.properties);
  }

  Future<Node?> createNode({required List<String> labels, required Map<String, dynamic> properties}) async {
    late Response response;
    String labelsString = "";

    if (labels.isNotEmpty) {
      labelsString = StringUtil.buildLabelString(labels);
    }

    if (properties.isNotEmpty) {
      response = await _createNodeWithPropertiesLabelsName(properties, labelsString);
    } else {
      throw NoParamNodeException(cause: "Trying to create node without properties");
    }

    return EntityUtil.convertResponseToNodeList(response).first;
  }

  ///TODO A TESTER
  Future<Response> _createNodeWithPropertiesLabelsName(
    Map<String, dynamic> properties,
    String label,
  ) async {
    for (final pair in properties.entries) {
      if(pair.value is String) properties[pair.key] = "\"${pair.value}\"";
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
      query: 'MATCH (a)-[r]->(b) WHERE id(r) = $id RETURN startNode(r), r, endNode(r), labels(a), labels(b)',
    );

    final deserializedValue = EntityUtil.convertResponseToRelationshipList(result);

    return deserializedValue.isNotEmpty ? deserializedValue.first : null;
  }

  Future<Relationship?> findRelationshipWithStartNodeIdEndNodeId(int startNodeId, int endNodeId) async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH (a)-[r]->(b) WHERE id(a) = $startNodeId AND id(b) = $endNodeId RETURN startNode(r), r, endNode(r), labels(a), labels(b)',
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

  Future<List<Node>> findAllNodesByProperties(List<PropertyToCheck> propertiesWithEqualityOperator) async {
    late String query;

    if(propertiesWithEqualityOperator.length == 1){
      query = "MATCH(n) WHERE n.${propertiesWithEqualityOperator.first.key} ${propertiesWithEqualityOperator.first.comparisonOperator} ${propertiesWithEqualityOperator.first.value}";
    } else if(propertiesWithEqualityOperator.length > 1){
      final buffer = StringBuffer("MATCH(n) WHERE n.");
      final iterator = propertiesWithEqualityOperator.iterator;

      while(iterator.moveNext()){
        buffer.write(iterator.current.key);
        buffer.write(iterator.current.comparisonOperator);
        buffer.write(iterator.current.value);

        if(iterator.current != propertiesWithEqualityOperator.last) {
          buffer.write(" AND n.");
        }
      }
      query = buffer.toString();
    }

    query += " RETURN n, labels(n)";

    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: query,
    );

    return EntityUtil.convertResponseToNodeList(result);
  }

  Future<Node> updateNodeWithId(int nodeId, Map<String, dynamic> propertiesToAddOrUpdate) async {
    String query = "MATCH(n) WHERE id(n)=$nodeId ";

    if(propertiesToAddOrUpdate.length == 1){
      query += "SET n.${propertiesToAddOrUpdate.keys.first}=${propertiesToAddOrUpdate.values.first}";
    } else if(propertiesToAddOrUpdate.length > 1){
      final buffer = StringBuffer("SET ");
      final iterator = propertiesToAddOrUpdate.entries.iterator;

      while(iterator.moveNext()){
        buffer.write("n.${iterator.current.key}");
        buffer.write("=");
        buffer.write(iterator.current.value);

        if(iterator.current.key != propertiesToAddOrUpdate.keys.last) {
          buffer.write(",");
        }
      }
      query += buffer.toString();
    }

    query += " RETURN n, labels(n)";
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: query,
    );

    return EntityUtil.convertResponseToNodeList(result).first;
  }

  Future<Relationship> updateRelationshipWithId(int relationshipId, Map<String, dynamic> propertiesToAddOrUpdate) async {
    String query = "MATCH(a)-[r]->(b) WHERE id(r) = $relationshipId ";

    if(propertiesToAddOrUpdate.length == 1){
      query += "SET r.${propertiesToAddOrUpdate.keys.first}=${propertiesToAddOrUpdate.values.first}";
    } else if(propertiesToAddOrUpdate.length > 1){
      final buffer = StringBuffer("SET ");
      final iterator = propertiesToAddOrUpdate.entries.iterator;

      while(iterator.moveNext()){
        buffer.write("r.${iterator.current.key}");
        buffer.write("=");
        buffer.write(iterator.current.value);

        if(iterator.current.key != propertiesToAddOrUpdate.keys.last) {
          buffer.write(",");
        }
      }
      query += buffer.toString();
    }

    query += " RETURN startNode(r), r, endNode(r), labels(a), labels(b)";
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: query,
    );
    return EntityUtil.convertResponseToRelationshipList(result).first;
  }

  Future<bool> isRelationshipExistsBetweenTwoNodes(int firstNode, int secondNode) async {
    final queryResult = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: "MATCH(a),(b) WHERE id(a)=$firstNode AND id(b)=$secondNode RETURN EXISTS((a)-[]-(b))",
    );
    return EntityUtil.convertResponseToBoolean(queryResult);
  }
}
