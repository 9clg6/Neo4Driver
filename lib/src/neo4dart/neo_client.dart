library neo4dart.neo_client;

import 'package:http/http.dart' show Client;
import 'package:neo4dart/src/model/node.dart';
import 'package:neo4dart/src/model/relationship.dart';
import 'package:neo4dart/src/service/neo_service.dart';

class NeoClient {
  late NeoService _neoService;

  /// Constructs NeoClient.
  /// Database's address can be added, otherwise the localhost address is used with Neo4J's default port is used (7474).
  NeoClient({String databaseAddress = 'http://localhost:7474/'}) {
    _neoService = NeoService(databaseAddress);
  }

  /// Constructs NeoClient with authentication credentials (user & password).
  /// Database's address can be added, otherwise the localhost address is used with Neo4J's default port is used (7474).
  /// Username and password are encoded to build the authentication token.
  ///
  /// If Token-authentication are not working, credentials can be added directly in the database's address following format
  /// http://username:password@localhost:7474
  NeoClient.withAuthorization({
    required String username,
    required String password,
    String databaseAddress = 'http://localhost:7474/',
  }) {
    _neoService = NeoService.withAuthorization(
      username: username,
      password: password,
      databaseAddress: databaseAddress,
    );
  }

  NeoClient.withHttpClient({required Client httpClient}) {
    _neoService = NeoService.withHttpClient(httpClient);
  }

  //#region CREATE METHODS
  /// Finds relationship with given ID (if id<0, return null).
  Future<Relationship?> findRelationshipById(int id) async {
    if (id >= 0) {
      return _neoService.findRelationshipById(id);
    } else {
      return null;
    }
  }

  /// Finds all nodes in database.
  /// Relationship are not return.
  Future<List<Node>> findAllNodes() async {
    return _neoService.findAllNodes();
  }

  Future<Node?> findNodeById(int id) async {
    return _neoService.findNodeById(id);
  }

  /// Finds all nodes in database with given type
  Future<List<Node>?> findAllNodesByLabel(String label) async {
    if (label != "" && label.isNotEmpty) {
      return _neoService.findAllNodesByLabel(label.replaceAll(' ', ''));
    } else {
      return null;
    }
  }
  //#endregion

  //#region CREATE METHODS
  Future<Relationship> createRelationship({
    required int startNodeId,
    required int endNodeId,
    required String relationName,
    required Map<String, dynamic> properties,
  }) {
    return _neoService.createRelationship(startNodeId, endNodeId, relationName, properties);
  }

  Future<List<Relationship>> createRelationshipFromNodeToNodes({
    required int startNodeId,
    required List<int> endNodesId,
    required String relationName,
    required Map<String, dynamic> properties,
  }) {
    return _neoService.createRelationshipFromNodeToNodes(startNodeId, endNodesId, relationName, properties);
  }

  Future<void> createNodeWithNode(Node node) {
    return _neoService.createNodeWithNodeParam(node);
  }

  Future<Node?> createNode({required List<String> labels, required Map<String, dynamic> properties}) async {
    return _neoService.createNode(labels: labels, properties: properties);
  }
  //#endregion

  //#region DELETE METHODS
  Future<void> deleteNodeById(int id) {
    return _neoService.deleteNodeById(id);
  }

  Future<void> deleteAllNode() {
    return _neoService.deleteAllNode();
  }
  //#endregion
}
