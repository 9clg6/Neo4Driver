library neo4dart.neo4dart_test;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:neo4dart/src/exception/no_param_node_exception.dart';
import 'package:neo4dart/src/utils/cypher_executor.dart';
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

  test('testNeoServiceCreateRelationship', () async {
    final result = await neoClient.createRelationship(
      startNodeId: 8,
      endNodeId: 9,
      relationName: "TEST_NUMBER_2",
      properties: {
        "name": "TEST_2",
        "test": 2,
      },
    );
    expect(8, result.startNode.id);
    expect(9, result.endNode.id);
  });

  test('testNeoServiceCreateNode', () async {
    final firstNode = await neoClient.createNode(
      labels: ['TESTType'],
      properties: {
        'name': 'TEST1',
        'prenom': 'TEST1',
        'age': 1,
      },
    );

    expect(true, firstNode?.label?.contains("TESTType"));
    expect('TEST1', firstNode?.properties['name']);
    expect('TEST1', firstNode?.properties['prenom']);
    expect("1", firstNode?.properties['age']);

    final secondNode = await neoClient.createNode(
      properties: {
        'name': 'TEST2',
        'prenom': 'TEST2',
        'age': 2,
      },
    );
    expect('TEST2', secondNode?.properties['name']);
    expect('TEST2', secondNode?.properties['prenom']);
    expect("2", secondNode?.properties['age']);

    expect(neoClient.createNode(properties: {}), throwsA(const TypeMatcher<NoParamNodeException>()));
  });

  test('testNeoServiceFindNodeById', () async {
    final nodes = await neoClient.findNodeById(6);

    expect(true, nodes?.label?.contains("Person"));
    expect("Philippe", nodes?.properties["name"]);
    expect("TEST", nodes?.properties["prenom"]);
    expect(20, nodes?.properties["age"]);
  });

  test('testNeoServicefindRelationshipById', () async {
    final nodes = await neoClient.findRelationshipById(0);
    expect(true, nodes != null);

    final nodes2 = await neoClient.findRelationshipById(0293480932);
    expect(true, nodes2 != null);
  });

  test('testNeoServiceFindAllNodesByType', () async {
    final nodes = await neoClient.findAllNodesByLabel('Person');
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
