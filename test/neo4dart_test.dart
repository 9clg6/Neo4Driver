library neo4dart.neo4dart_test;

import 'dart:convert';
import 'package:http/http.dart';
import 'package:neo4dart/src/exception/no_param_node_exception.dart';
import 'package:neo4dart/src/utils/cypher_executor.dart';
import 'package:neo4dart/src/entity/entity.dart';
import 'package:neo4dart/src/enum/http_method.dart';
import 'package:neo4dart/src/neo4dart/neo_client.dart';
import 'package:test/test.dart';

void main() {
  late NeoClient neoClient;

  setUp(() {
    neoClient = NeoClient.withAuthorization(
      username: 'neo4j',
      password: 'root',
      databaseAddress: 'http://localhost:7474/',
    );
  });

  test('testNeoServiceCreateRelationshipToMultipleNodes', () async {
    final result = await neoClient.createRelationshipFromNodeToNodes(
      startNodeId: 12,
      endNodesId: [14,15,16],
      relationName: "BROTHER_OF",
      properties: {
        'test1': 'test',
        'test11': 1,
      },
    );

    expect(true, result.isNotEmpty);
    expect(true, result.where((rel) => rel.endNode.id == 14).isNotEmpty);
    expect(true, result.where((rel) => rel.endNode.id == 15).isNotEmpty);
    expect(true, result.where((rel) => rel.endNode.id == 15).isNotEmpty);
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
    const label = 'Person1';
    const name = 'Guyon1';
    const surname = 'Clement1';
    const age = '1';

    final firstNode = await neoClient.createNode(
      labels: [label],
      properties: {
        'name': name,
        'prenom': surname,
        'age': age,
      },
    );

    expect(true, firstNode?.label.contains(label));
    expect(name, firstNode?.properties['name']);
    expect(surname, firstNode?.properties['prenom']);
    expect(age, firstNode?.properties['age']);

    const name2 = 'Guyon2';
    const surname2 = 'Clement2';
    const age2 = '2';

    final secondNode = await neoClient.createNode(
      labels: [label],
      properties: {
        'name': name2,
        'prenom': surname2,
        'age': age2,
      },
    );
    expect(name2, secondNode?.properties['name']);
    expect(surname2, secondNode?.properties['prenom']);
    expect(age2, secondNode?.properties['age']);

    expect(
      neoClient.createNode(labels: [label], properties: {}),
      throwsA(const TypeMatcher<NoParamNodeException>()),
    );
  });

  test('testNeoServiceFindNodeById', () async {
    final nodes = await neoClient.findNodeById(14);

    expect(true, nodes?.label.contains("Person1"));
    expect("Clement2", nodes?.properties["prenom"]);
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
}
