library neo4dart.neo_client;

import 'dart:convert';
import 'package:http/http.dart' show Client;
import 'package:neo4dart/src/model/node.dart';
import 'package:neo4dart/src/model/relationship.dart';
import 'package:neo4dart/src/service/neo_service.dart';

class NeoClient {
  late Client httpClient = Client();
  late NeoService _neoService;

  String? token;
  String databaseAddress;

  NeoClient({required this.databaseAddress}){
    _neoService = NeoService(this);
  }

  NeoClient.withAuthorization({
    required String username,
    required String password,
    required this.databaseAddress,
  }) {
    token = base64Encode(utf8.encode("$username:$password"));
    _neoService = NeoService(this);
  }

  Future<List<Relationship>> findRelationshipById(int id) async {
    return _neoService.findRelationshipById(id);
  }

  Future<List<Node>> findAllNodes() async {
    return _neoService.findAllNodes();
  }

  Future<List<Node>> findAllNodesByType(String type) async {
    return _neoService.findAllNodesByLabel(type);
  }

}
