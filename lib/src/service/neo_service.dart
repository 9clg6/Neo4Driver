import 'dart:convert';

import 'package:http/http.dart';

import '../../neo4driver.dart';
import '../entity/path.dart';
import '../enum/http_method.dart';
import '../utils/cypher_executor.dart';
import '../utils/entity_util.dart';
import '../utils/string_util.dart';

class NeoService {
  late CypherExecutor _cypherExecutor;

  //#region CONSTRUCTORS
  /// Constructs NeoService with database address [databaseAddress]
  NeoService(String databaseAddress) {
    _cypherExecutor = CypherExecutor(databaseAddress: databaseAddress);
  }

  /// Constructs NeoService with HTTP Client [client]
  NeoService.withHttpClient(Client client) {
    _cypherExecutor = CypherExecutor.withHttpClient(httpClient: client);
  }

  /// Constructs NeoService with credentials (username [username], password [password]) and database address ([databaseAddress] if different from localhost
  NeoService.withAuthorization({
    required String username,
    required String password,
    String databaseAddress = 'http://localhost:7474/',
  }) {
    _cypherExecutor = CypherExecutor.withAuthorization(username, password, databaseAddress);
  }
  //#endregion

  //#region CREATE RELATIONSHIP
  /// Create relationship between one to many nodes (1->*)
  ///
  /// Nodes are identified by their ID [endNodesId].
  /// Relationship can starts only from ONE node [startNodeId]
  /// [relationName] represents the name of the relationship
  /// [properties] are properties of the relationship
  Future<List<Relationship?>> createRelationshipFromNodeToNodes(
    int startNodeId,
    List<int> endNodesId,
    String relationName,
    Map<String, dynamic> properties,
  ) async {
    List<Relationship?> relationShipList = [];

    for (final nodeId in endNodesId) {
      final rel = await createRelationship(
        startNodeId,
        nodeId,
        relationName,
        Map.from(properties),
      );

      relationShipList.add(rel);
    }
    return relationShipList;
  }

  /// Create relationship between two nodes : start node [startNodeId] and end node [endNodeId]
  /// The relationship has a name [relationName] and can have properties [properties]
  Future<Relationship?> createRelationship(
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

    final convertedResponse = EntityUtil.convertResponseToRelationshipList(response);

    return convertedResponse.isNotEmpty ? convertedResponse.first : null;
  }
  //#endregion

  //#region CREATE NODE
  /// Create Neo4J node with given [node]
  Future<Node?> createNodeWithNode(Node node) async {
    if (node.properties.isNotEmpty) {
      if (node.labels.isNotEmpty) {
        return createNode(
          labels: node.labels,
          properties: node.properties,
        );
      }
      throw NoLabelNodeException(cause: "Node must have labels to be created");
    }
    throw NoPropertiesException(cause: "Node must have properties to be created");
  }

  /// Create Neo4J node
  ///
  /// Node must have [labels] and [properties] to be created
  Future<Node?> createNode({required List<String> labels, required Map<String, dynamic> properties}) async {
    late Response response;
    String labelsString = "";

    //Transform list of labels in single string, if multiple labels : (:..., ...)
    if (labels.isNotEmpty && labels.every((label) => label != "" && label.isNotEmpty)) {
      labelsString = StringUtil.buildLabelString(labels);
    } else {
      throw NoLabelNodeException(cause: "Node must have labels to be created");
    }

    if (properties.isNotEmpty) {
      response = await _createNodeWithPropertiesLabelsName(properties, labelsString);
    } else {
      throw NoParamNodeException(cause: "Node must have properties to be created");
    }
    final convertedResponse = EntityUtil.convertResponseToNodeList(response);

    return convertedResponse.isNotEmpty ? convertedResponse.first : null;
  }

  /// Create Neo4J Node
  Future<Response> _createNodeWithPropertiesLabelsName(
    Map<String, dynamic> properties,
    String label,
  ) async {
    //Put \" on string properties
    for (final pair in properties.entries) {
      if (pair.value is String) properties[pair.key] = "\"${pair.value}\"";
    }

    return await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'CREATE (n:$label $properties) RETURN n, labels(n)',
    );
  }
  //#endregion

  //#region DELETE NODE
  /// Deletes all nodes in the database.
  /// /!\ Transaction commits at submission.
  Future<void> deleteAllNode() async {
    await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH (n) DETACH DELETE n',
    );
  }

  /// Delete node corresponding to the given id [id]
  Future<void> deleteNodeById(int id) async {
    await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n) WHERE id(n)=$id DETACH DELETE n',
    );
  }
  //#endregion

  //#region FIND RELATIONSHIP
  /// Find relationship corresponding to the given id [id]
  Future<Relationship?> findRelationshipById(int id) async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH (a)-[r]->(b) WHERE id(r) = $id RETURN startNode(r), r, endNode(r), labels(a), labels(b)',
    );

    final deserializedValue = EntityUtil.convertResponseToRelationshipList(result);

    return deserializedValue.isNotEmpty ? deserializedValue.first : null;
  }

  /// Find relationship with start node id [startNodeId] and end node id [endNodeId]
  Future<Relationship?> findRelationshipWithStartNodeIdEndNodeId(int startNodeId, int endNodeId) async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query:
          'MATCH (a)-[r]->(b) WHERE id(a) = $startNodeId AND id(b) = $endNodeId RETURN startNode(r), r, endNode(r), labels(a), labels(b)',
    );

    final convertedResult = EntityUtil.convertResponseToRelationshipList(result);

    return convertedResult.isNotEmpty ? convertedResult.first : null;
  }

  /// Find all relationship
  Future<List<Relationship>> findAllRelationship() async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(a)-[r]–>(b) RETURN startNode(r), r, endNode(r), labels(a), labels(b)',
    );
    return EntityUtil.convertResponseToRelationshipList(result);
  }

  /// Find relationship of a node with node [properties]
  Future<List<Relationship>> findRelationshipWithNodeProperties(Map<String, dynamic> properties, String label) async {
    String query = "MATCH (a:$label)-[r]-(b)";

    if (properties.length == 1) {
      if (properties.values.first is String) {
        query += " WHERE a.${properties.keys.first}='${properties.values.first}'";
      } else {
        query += " WHERE a.${properties.keys.first}=${properties.values.first}";
      }
    } else if (properties.length > 1) {
      final buffer = StringBuffer(" WHERE ");
      final iterator = properties.entries.iterator;

      while (iterator.moveNext()) {
        buffer.write("a.${iterator.current.key}");
        buffer.write("= ");
        buffer.write(iterator.current.value);

        if (iterator.current.key != properties.keys.last) {
          buffer.write(" AND ");
        }
      }
      query += buffer.toString();
    }
    query += " RETURN startNode(r), r, endNode(r), labels(a), labels(b)";

    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: query,
    );

    return EntityUtil.convertResponseToRelationshipList(result);
  }
  //#endregion

  //#region FIND NODE
  /// Find all nodes in Neo4J database
  Future<List<Node>> findAllNodes() async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n) RETURN n, labels(n)',
    );
    return EntityUtil.convertResponseToNodeList(result);
  }

  /// Find all nodes with the given [label]
  Future<List<Node>> findAllNodesByLabel(String label) async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n:$label) RETURN(n)',
    );
    return EntityUtil.convertResponseToNodeList(result);
  }

  /// Find node with the given [id]
  Future<Node?> findNodeById(int id) async {
    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: 'MATCH(n) WHERE id(n)=$id RETURN n, labels(n)',
    );
    final convertedResult = EntityUtil.convertResponseToNodeList(result);

    return convertedResult.isNotEmpty ? convertedResult.first : null;
  }

  /// Find all nodes with given [propertiesWithEqualityOperator]
  Future<List<Node>> findAllNodesByProperties(List<PropertyToCheck> propertiesWithEqualityOperator) async {
    late String query;
    final buffer = StringBuffer("MATCH(n) WHERE n.");

    if (propertiesWithEqualityOperator.length == 1) {
      buffer.write(propertiesWithEqualityOperator.first.key);
      buffer.write(" ${propertiesWithEqualityOperator.first.comparisonOperator} ");
      buffer.write("${propertiesWithEqualityOperator.first.value}");
      query = buffer.toString();
    } else if (propertiesWithEqualityOperator.length > 1) {
      final iterator = propertiesWithEqualityOperator.iterator;

      while (iterator.moveNext()) {
        buffer.write(iterator.current.key);
        buffer.write(iterator.current.comparisonOperator);
        buffer.write(iterator.current.value);

        if (iterator.current != propertiesWithEqualityOperator.last) {
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
  //#endregion

  //#region UPDATE NODE
  /// Update node corresponding to the given [nodeId] with [propertiesToAddOrUpdate]
  Future<Node?> updateNodeById(int nodeId, Map<String, dynamic> propertiesToAddOrUpdate) async {
    String query = "MATCH(n) WHERE id(n)=$nodeId ";

    if (propertiesToAddOrUpdate.length == 1) {
      if (propertiesToAddOrUpdate.values.first is String) {
        query += "SET n.${propertiesToAddOrUpdate.keys.first}='${propertiesToAddOrUpdate.values.first}'";
      } else {
        query += "SET n.${propertiesToAddOrUpdate.keys.first}=${propertiesToAddOrUpdate.values.first}";
      }
    } else if (propertiesToAddOrUpdate.length > 1) {
      final buffer = StringBuffer("SET ");
      final iterator = propertiesToAddOrUpdate.entries.iterator;

      while (iterator.moveNext()) {
        buffer.write("n.${iterator.current.key}");
        buffer.write("=");
        if (iterator.current.value is String) {
          buffer.write("'${iterator.current.value}'");
          buffer.write("'${iterator.current.value}'");
        } else {
          buffer.write(iterator.current.value);
        }

        if (iterator.current.key != propertiesToAddOrUpdate.keys.last) {
          buffer.write(",");
        }
      }
      query += buffer.toString();
    } else if (propertiesToAddOrUpdate.isEmpty) {
      throw NoPropertiesException(cause: "properties are necessary to find node with given properties");
    }

    query += " RETURN n, labels(n)";

    final result = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: query,
    );

    final conversionResult = EntityUtil.convertResponseToNodeList(result);

    return conversionResult.isNotEmpty ? conversionResult.first : null;
  }
  //#endregion

  //#region UPDATE RELATIONSHIP
  /// Update Relationship corresponding to the given [relationshipId] with [propertiesToAddOrUpdate]
  Future<Relationship?> updateRelationshipById(
    int relationshipId,
    Map<String, dynamic> propertiesToAddOrUpdate,
  ) async {
    String concatProp = "";
    String query = "MATCH(a)-[r]->(b) WHERE id(r) = $relationshipId ";

    if (propertiesToAddOrUpdate.length == 1) {
      if (propertiesToAddOrUpdate.values.first is String) {
        concatProp = "'${propertiesToAddOrUpdate.values.first}'";
      }
      query += "SET r.${propertiesToAddOrUpdate.keys.first}=$concatProp";
    } else if (propertiesToAddOrUpdate.length > 1) {
      final buffer = StringBuffer("SET ");
      final iterator = propertiesToAddOrUpdate.entries.iterator;

      while (iterator.moveNext()) {
        buffer.write("r.${iterator.current.key}");
        buffer.write("=");

        if (iterator.current.value is String) {
          buffer.write("'${iterator.current.value}'");
          buffer.write("'${iterator.current.value}'");
        } else {
          buffer.write(iterator.current.value);
        }
        if (iterator.current.key != propertiesToAddOrUpdate.keys.last) {
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

    final convertedResult = EntityUtil.convertResponseToRelationshipList(result);

    return convertedResult.isNotEmpty ? convertedResult.first : null;
  }
  //#endregion

  //#region CHECK EXISTENCE
  /// Check if a relationship exists between two nodes [firstNode] and [secondNode]
  Future<bool> isRelationshipExistsBetweenTwoNodes(int firstNode, int secondNode) async {
    final queryResult = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: "MATCH(a),(b) WHERE id(a)=$firstNode AND id(b)=$secondNode RETURN EXISTS((a)-[]-(b))",
    );
    return EntityUtil.convertResponseToBoolean(queryResult);
  }

  /// Compute the shortest path between two nodes
  /// If Path is empty it could means that there is no path between the two given nodes
  Future<Path> computeShortestPathDijkstra(
    double sourceLat,
    double sourceLong,
    double targetLat,
    double targetLong,
    String projectionName,
    String propertyWeight,
  ) async {
    final sb = StringBuffer();

    sb.write("MATCH (source:Point {latitude: $sourceLat, longitude: $sourceLong}) ");
    sb.write("MATCH (target:Point {latitude: $targetLat, longitude: $targetLong}) ");
    sb.write("CALL gds.shortestPath.dijkstra.stream('$projectionName', ");
    sb.write("{sourceNode: source, targetNode: target, relationshipWeightProperty: '$propertyWeight'}) ");
    sb.write("YIELD nodeIds, path ");
    sb.write("RETURN nodes(path) as path");

    final queryResult = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: sb.toString(),
    );

    return EntityUtil.convertResponseToPath(queryResult);
  }

  //#endregion

  Future<List<Relationship>> getNodesWithHighestProperty(int limit, String propertyName) async {
    final queryResult = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query:
          "MATCH (a:Point)-[r]->(b) RETURN startNode(r), r, endNode(r), labels(a), labels(b) ORDER BY a.$propertyName ASC LIMIT $limit",
    );

    return EntityUtil.convertResponseToRelationshipList(queryResult);
  }

  //#region PROJECTION
  /// Create a projection of the graph at the T instant
  Future<bool> createGraphProjection(
    String projectionName,
    String label,
    String relationshipName,
    String relationshipProperty,
    bool isDirected,
  ) async {
    final sb = StringBuffer();
    String orientation = isDirected ? "NATURAL" : "UNDIRECTED";

    sb.write(
        "CALL gds.graph.project('$projectionName', '$label', { $relationshipName: { properties: '$relationshipProperty', orientation: '$orientation' }}) ");
    sb.write(
        "YIELD graphName AS graph, relationshipProjection AS prevProjection, nodeCount AS nodes, relationshipCount AS rels");
    final sbQuery = sb.toString();

    final queryResult = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query: sbQuery,
    );
    final jsonResult = jsonDecode(queryResult.body);

    return jsonResult["errors"].isEmpty;
  }
  //#endregion

  //#region DISTANCE
  /// Compute the distance between two points
  Future<num> computeDistanceBetweenTwoPoints(double latP1, double longP1, double latP2, double longP2) async {
    final queryResult = await _cypherExecutor.executeQuery(
      method: HTTPMethod.post,
      query:
          "WITH point({latitude: $latP1, longitude: $longP1}) AS p1, point({latitude: $latP2, longitude: $longP2}) AS p2 RETURN point.distance(p1,p2)/1000 AS dist",
    );
    return EntityUtil.convertResponseToDouble(queryResult);
  }
  //#endregion
}
