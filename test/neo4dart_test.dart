library neo4dart.neo4dart_test;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:neo4dart/src/cypher_executor.dart';
import 'package:neo4dart/src/entity/entity.dart';
import 'package:neo4dart/src/enum/http_method.dart';
import 'package:neo4dart/src/neo4dart/neo_client.dart';
import 'dart:io';

void main() {
  late NeoClient neoClient;

  setUp(() {
    neoClient = NeoClient.withAuthorization(
      username: 'neo4j',
      password: 'root',
      databaseAddress: 'http://localhost:7474/',
    );
  });

  test('testNeoServiceCreateNode', () async {
    await neoClient.createNode('Henry', ['Person'], {
      'prenom': 'Henry2',
      'age': 2,
    });
  });

  test('testNeoServiceFindNodeById', () async {
    final nodes = await neoClient.findNodeById(6);

    expect(true, nodes.label?.contains("Person"));
    expect("Philippe", nodes.name);
    expect("TEST", nodes.properties["prenom"]);
    expect(20, nodes.properties["age"]);
  });

  test('testNeoServicefindRelationshipById', () async {
    final nodes = await neoClient.findRelationshipById(0);
    expect(true, nodes?.isNotEmpty);

    final nodes2 = await neoClient.findRelationshipById(0293480932);
    expect(true, nodes2?.isEmpty);
  });

  test('testNeoServiceFindAllNodesByType', () async {
    final nodes = await neoClient.findAllNodesByType('Person');
    expect(true, nodes?.isNotEmpty);
  });

  test('testNeoServiceFindAllNodes', () async {
    final nodes = await neoClient.findAllNodes();
    expect(true, nodes.isNotEmpty);
  });

  test('testNodeEntityDeserialization', () async {
    List<Entity> nodeEntityList = [];

    final executor = CypherExecutor(neoClient);
    Response result = await executor.executeQuery(method: HTTPMethod.post, query: 'MATCH(n) RETURN n');
    final body = jsonDecode(result.body);
    final data = body["results"].first["data"] as List;

    for (final element in data) {
      nodeEntityList.add(Entity.fromJson(element));
    }

    expect(true, nodeEntityList.isNotEmpty);
  });

  test('testCypherExecutor', () async {
    final executor = CypherExecutor(neoClient);
    Response result = await executor.executeQuery(method: HTTPMethod.post, query: 'MATCH(n) RETURN n');
    expect(result.statusCode, 200);
  });

  test('testLocalRequestWithAuthentication', () async {
    Response result = await neoClient.httpClient.post(
      Uri.parse('${neoClient.databaseAddress}db/neo4j/tx/commit'),
      body: const JsonEncoder().convert(
        {
          "statements": [
            {
              "statement": 'MATCH(n) RETURN n',
            },
          ]
        },
      ),
      headers: {HttpHeaders.authorizationHeader: neoClient.token!, 'content-Type': 'application/json'},
    );
    expect(result.statusCode, 200);
  });
}
