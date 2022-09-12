library neo4dart.neo_client;

import 'package:http/http.dart' show Client;
import 'package:neo4dart/src/entity/path.dart';
import 'package:neo4dart/src/exception/invalid_id_exception.dart';
import 'package:neo4dart/src/exception/no_label_node_exception.dart';
import 'package:neo4dart/src/exception/no_param_node_exception.dart';
import 'package:neo4dart/src/exception/no_properties_exception.dart';
import 'package:neo4dart/src/exception/not_enough_id_exception.dart';
import 'package:neo4dart/src/model/node.dart';
import 'package:neo4dart/src/model/property_to_check.dart';
import 'package:neo4dart/src/model/relationship.dart';
import 'package:neo4dart/src/service/neo_service.dart';

class NeoClient {
  NeoClient._internal();
  late NeoService _neoService;
  static final NeoClient _instance = NeoClient._internal();

  /// Constructs NeoClient.
  /// Database's address can be added, otherwise the localhost address is used with Neo4J's default port is used (7474).
  factory NeoClient() => _instance;

  factory NeoClient.withoutCredentialsForTest({String databaseAddress = 'http://localhost:7474/'}) {
    _instance._neoService = NeoService(databaseAddress);
    return _instance;
  }

  /// Constructs NeoClient with authentication credentials (user & password).
  /// Database's address can be added, otherwise the localhost address is used with Neo4J's default port is used (7474).
  /// Username and password are encoded to build the authentication token.
  ///
  /// If Token-authentication is not working, credentials can be added directly in the database's address following format
  /// http://username:password@localhost:7474
  factory NeoClient.withAuthorization({
    required String username,
    required String password,
    String databaseAddress = 'http://localhost:7474/',
  }) {
    _instance._neoService = NeoService.withAuthorization(
      username: username,
      password: password,
      databaseAddress: databaseAddress,
    );
    return _instance;
  }

  factory NeoClient.withHttpClient({required Client httpClient}) {
    _instance._neoService = NeoService.withHttpClient(httpClient);
    return _instance;
  }

  //#region CREATE METHODS
  /// Finds relationship with given ID (if id<0, return null).
  Future<Relationship?> findRelationshipById(int id) async {
    if (id >= 0) {
      return _neoService.findRelationshipById(id);
    } else {
      throw InvalidIdException(cause: "ID can't be negative");
    }
  }

  Future<List<Relationship>> findAllRelationship() async {
    return await _neoService.findAllRelationship();
  }

  /// Find relationship with start node id [startNodeId] and end node id [endNodeId]
  Future<Relationship?> findRelationshipWithStartNodeIdEndNodeId(int startNode, int endNode) async {
    if (startNode >= 0 && endNode >= 0) {
      return _neoService.findRelationshipWithStartNodeIdEndNodeId(startNode, endNode);
    } else {
      throw InvalidIdException(cause: "ID can't be < 0");
    }
  }

  /// Find relationship of a node with node [properties]
  Future<List<Relationship?>> findRelationshipWithNodeProperties({
    required String relationshipLabel,
    required Map<String, dynamic> properties,
  }) async {
    if (properties.isNotEmpty) {
      return _neoService.findRelationshipWithNodeProperties(properties, relationshipLabel);
    } else {
      throw NoParamNodeException(cause: "To find nodes parameters are needed");
    }
  }

  /// Check if a relationship exists between two nodes [firstNode] and [secondNode]
  Future<bool> isRelationshipExistsBetweenTwoNodes(int firstNode, int secondNode) {
    if (firstNode >= 0 && secondNode >= 0) {
      return _neoService.isRelationshipExistsBetweenTwoNodes(firstNode, secondNode);
    } else {
      throw InvalidIdException(cause: "ID can't be negative");
    }
  }

  /// Update node corresponding to the given [nodeId] with [propertiesToAddOrUpdate]
  Future<Node?> updateNodeById({
    required int nodeId,
    required Map<String, dynamic> propertiesToAddOrUpdate,
  }) {
    if (nodeId >= 0) {
      if (propertiesToAddOrUpdate.isNotEmpty) {
        return _neoService.updateNodeById(nodeId, propertiesToAddOrUpdate);
      } else {
        throw NoPropertiesException(cause: "Properties map is empty");
      }
    } else {
      throw InvalidIdException(cause: "ID can't be negative");
    }
  }

  /// Update Relationship corresponding to the given [relationshipId] with [propertiesToAddOrUpdate]
  Future<Relationship?> updateRelationshipById({
    required int relationshipId,
    required Map<String, dynamic> propertiesToAddOrUpdate,
  }) {
    if (relationshipId >= 0) {
      if (propertiesToAddOrUpdate.isNotEmpty) {
        return _neoService.updateRelationshipById(relationshipId, propertiesToAddOrUpdate);
      } else {
        throw NoPropertiesException(cause: "Properties map is empty");
      }
    } else {
      throw InvalidIdException(cause: "ID can't be negative");
    }
  }

  /// Find all nodes with given properties
  /// Relationship not returned
  Future<List<Node>> findAllNodesByProperties({required List<PropertyToCheck> propertiesToCheck}) {
    if (propertiesToCheck.isNotEmpty) {
      return _neoService.findAllNodesByProperties(propertiesToCheck);
    } else {
      throw NoPropertiesException(cause: "Can't search nodes by properties with empty properties list");
    }
  }

  /// Finds all nodes in database.
  /// Relationship are not return.
  Future<List<Node>> findAllNodes() async {
    return _neoService.findAllNodes();
  }

  Future<Node?> findNodeById(int id) async {
    if (id >= 0) {
      return _neoService.findNodeById(id);
    } else {
      throw InvalidIdException(cause: "ID can't be negative");
    }
  }

  /// Finds all nodes in database with given type
  Future<List<Node>> findAllNodesByLabel(String label) async {
    if (label != "" && label.isNotEmpty) {
      return _neoService.findAllNodesByLabel(label.replaceAll(' ', ''));
    } else {
      throw NoLabelNodeException(cause: "Label must be defined");
    }
  }

  //#endregion

  Future<List<Relationship>> getNodesWithHighestProperty(int limit, String propertyName) {
    return _neoService.getNodesWithHighestProperty(limit, propertyName);
  }

  /// Compute the shortest path between two nodes
  /// If Path is empty it could means that there is no path between the two given nodes
  Future<Path> computeShortestPathDijkstra({
    required double sourceLat,
    required double sourceLong,
    required double targetLat,
    required double targetLong,
    required String projectionName,
    required String propertyWeightName,
  }) {
    return _neoService.computeShortestPathDijkstra(
      sourceLat,
      sourceLong,
      targetLat,
      targetLong,
      projectionName,
      propertyWeightName,
    );
  }

  /// Compute the distance between two points
  Future<num> computeDistanceBetweenTwoPoints({
    required double latP1,
    required double longP1,
    required double latP2,
    required double longP2,
  }) {
    return _neoService.computeDistanceBetweenTwoPoints(latP1, longP1, latP2, longP2);
  }

  //#region PROJECTION
  /// Create a projection of the graph at the T instant
  Future<bool> createGraphProjection({
    required String projectionName,
    required String label,
    required String relationshipName,
    required String relationshipProperty,
    required bool isDirected,
  }) {
    return _neoService.createGraphProjection(
      projectionName,
      label,
      relationshipName,
      relationshipProperty,
      isDirected,
    );
  }
  //#endregion

  //#region CREATE METHODS
  /// Create relationship between two nodes : start node [startNodeId] and end node [endNodeId]
  /// The relationship has a name [relationshipLabel] and can have properties [properties]
  Future<Relationship?> createRelationship({
    required int startNodeId,
    required int endNodeId,
    required String relationshipLabel,
    required Map<String, dynamic> properties,
  }) {
    if (startNodeId >= 0 && endNodeId >= 0) {
      return _neoService.createRelationship(startNodeId, endNodeId, relationshipLabel, properties);
    } else {
      throw InvalidIdException(cause: "ID can't be negative");
    }
  }

  /// Create relationship between one to many nodes (1->*)
  ///
  /// Nodes are identified by their ID [endNodesId].
  /// Relationship can starts only from ONE node [startNodeId]
  /// [relationName] represents the name of the relationship
  /// [properties] are properties of the relationship
  Future<List<Relationship?>> createRelationshipFromNodeToNodes({
    required int startNodeId,
    required List<int> endNodesId,
    required String relationName,
    required Map<String, dynamic> properties,
  }) {
    if (endNodesId.length > 1) {
      if (startNodeId >= 0 && endNodesId.every((id) => id >= 0)) {
        return _neoService.createRelationshipFromNodeToNodes(startNodeId, endNodesId, relationName, properties);
      } else {
        throw InvalidIdException(cause: "ID can't be negative");
      }
    } else {
      throw NotEnoughIdException(cause: "More than 1 id is needed");
    }
  }

  /// Create Neo4J node with given [node]
  Future<void> createNodeWithNode(Node node) {
    return _neoService.createNodeWithNode(node);
  }

  /// Create Neo4J node
  ///
  /// Node must have [labels] and [properties] to be created
  Future<Node?> createNode({required List<String> labels, required Map<String, dynamic> properties}) async {
    return _neoService.createNode(labels: labels, properties: properties);
  }
  //#endregion

  //#region DELETE METHODS
  /// Delete node corresponding to the given id [id]
  Future<void> deleteNodeById(int id) {
    if (id >= 0) {
      return _neoService.deleteNodeById(id);
    } else {
      throw InvalidIdException(cause: "ID can't be negative");
    }
  }

  /// Deletes all nodes in the database.
  /// /!\ Transaction commits at submission.
  Future<void> deleteAllNode() {
    return _neoService.deleteAllNode();
  }
  //#endregion
}
