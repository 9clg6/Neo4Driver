library neo4dart.neo4dart_test;

import 'dart:io';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:neo4dart/src/model/node.dart';
import 'package:neo4dart/src/model/property_to_check.dart';
import 'package:neo4dart/src/model/relationship.dart';
import 'package:neo4dart/src/neo4dart/neo_client.dart';
import 'package:neo4dart/src/utils/string_util.dart';
import 'package:test/test.dart';

void main() {
  late NeoClient neoClient;

  group('testSingleton', () {
    NeoClient singleton1 = NeoClient.withoutCredentialsForTest();
    NeoClient singleton2 = NeoClient.withoutCredentialsForTest();
    late NeoClient singleton3;
    late NeoClient singleton4;

    setUp(() {
      final client200_1 = MockClient((_) async {
        return Response("OK", 200);
      });

      final client200_2 = MockClient((_) async {
        return Response("OK", 200);
      });

      singleton3 = NeoClient.withHttpClient(httpClient: client200_1);
      singleton4 = NeoClient.withHttpClient(httpClient: client200_2);
    });

    test('singleton', () {
      expect(true, singleton1 == singleton2);
      expect(true, singleton3 == singleton4);
    });
  });

  group('testFindByProperties', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/findNodesByProperties_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('test', () async {
      final test = await neoClient.findAllNodesByProperties(
        propertiesToCheck: [
          PropertyToCheck(
            key: "latitude",
            comparisonOperator: ">=",
            value: 45.75,
          ),
          PropertyToCheck(
            key: "longitude",
            comparisonOperator: ">=",
            value: 4.85,
          ),
        ],
      );

      final test2 = await neoClient.findAllNodesByProperties(
        propertiesToCheck: [
          PropertyToCheck(
            key: "latitude",
            comparisonOperator: ">=",
            value: 45.75,
          ),
        ],
      );

      expect(true, test.isNotEmpty);
      expect(true, test2.isNotEmpty);
      expect(() => neoClient.findAllNodesByProperties(propertiesToCheck: []), throwsException);
    });
  });

  group('testCreateRelationship', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/insertRelationship_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceCreateRelationship', () async {
      final result = await neoClient.createRelationship(
        startNodeId: 12,
        endNodeId: 14,
        relationshipLabel: "TEST_NUMBER_2",
        properties: {
          "name": "TEST_2",
          "test": 2,
        },
      );

      expect(12, result?.startNode.id);
      expect(14, result?.endNode.id);

      expect(
        () => neoClient.createRelationship(
          startNodeId: -1,
          endNodeId: 14,
          relationshipLabel: "TEST_NUMBER_2",
          properties: {
            "name": "TEST_2",
            "test": 2,
          },
        ),
        throwsException,
      );

      expect(
        () => neoClient.createRelationship(
          startNodeId: 12,
          endNodeId: -133,
          relationshipLabel: "TEST_NUMBER_2",
          properties: {
            "name": "TEST_2",
            "test": 2,
          },
        ),
        throwsException,
      );
    });
  });

  group('testCreateNode', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/insertNode_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceInsertNode', () async {
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

      expect(
        () => neoClient.createNode(
          labels: [],
          properties: {
            'name': name,
            'prenom': surname,
            'age': age,
          },
        ),
        throwsException,
      );
      expect(() => neoClient.createNode(labels: [label], properties: {}), throwsException);
      expect(true, firstNode?.labels.contains(label));
      expect(name, firstNode?.properties['name']);
      expect(surname, firstNode?.properties['prenom']);
      expect(age, firstNode?.properties['age']);
    });
  });

  group('testFindNodeById', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/findNodeById_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceFindNodeById', () async {
      final nodes = await neoClient.findNodeById(14);

      expect(true, nodes?.labels.contains("Person1"));
      expect("Clement2", nodes?.properties["prenom"]);
      expect(() => neoClient.findNodeById(-1), throwsException);
    });
  });

  group('testFindRelationshipById', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/findRelationshipById_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceFindRelationshipById', () async {
      final relationship = await neoClient.findRelationshipById(0);

      expect(12, relationship?.startNode.id);
      expect(14, relationship?.endNode.id);
      expect(() => neoClient.findRelationshipById(-1), throwsException);
    });
  });

  group('testFindAllNodesByLabel', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/findAllNodesByLabel_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceFindAllNodesByType', () async {
      final nodes = await neoClient.findAllNodesByLabel('Person1');
      expect("Clement1", nodes.first.properties["prenom"]);
    });
  });

  group('testFindAllNodes', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/findAllNodes_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceFindAllNodes', () async {
      final nodes = await neoClient.findAllNodes();
      expect(true, nodes.isNotEmpty);
    });
  });

  group('testFindRelationshipWithStartNodeIdEndNodeId', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/findRelationshipWithStartNodeIdEndNodeId_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceFindRelationshipWithStartNodeIdEndNodeId', () async {
      final rel = await neoClient.findRelationshipWithStartNodeIdEndNodeId(1, 2);
      expect(true, rel != null);
      expect(()=> neoClient.findRelationshipWithStartNodeIdEndNodeId(-1, 2), throwsException);
      expect(()=> neoClient.findRelationshipWithStartNodeIdEndNodeId(1, -2), throwsException);
    });
  });

  group('testFindRelationshipWithNodeProperties', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/findRelationshipWithNodeProperties_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceFindRelationshipWithNodeProperties', () async {
      final rel = await neoClient.findRelationshipWithNodeProperties(relationshipLabel: "TestRel", properties: {
        "name": "test1",
      });
      expect(true, rel.isNotEmpty);
      expect(
        () => neoClient.findRelationshipWithNodeProperties(
          relationshipLabel: "TestRel",
          properties: {},
        ),
        throwsException,
      );
    });
  });

  group('testIsRelationshipExistsBetweenTwoNodes', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/isRelationshipExistsBetweenTwoNodes_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceIsRelationshipExistsBetweenTwoNodes', () async {
      final result = await neoClient.isRelationshipExistsBetweenTwoNodes(2, 3);
      expect(true, result);
      expect(()=>neoClient.isRelationshipExistsBetweenTwoNodes(-2, 3), throwsException);
      expect(()=>neoClient.isRelationshipExistsBetweenTwoNodes(2, -3), throwsException);
    });
  });

  group('testUpdateNodeById', () {
    late NeoClient client2;
    late Node? node;
    late Node? modifiedNode;

    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/updateNodeById.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceTestUpdateNodeById', () async {
      node = await neoClient.findNodeById(0);

      final client200_2 = MockClient((request) async {
        final responseBody = File('test/json/updateNodeById_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      client2 = NeoClient.withHttpClient(httpClient: client200_2);

      modifiedNode = await client2.updateNodeById(
        nodeId: 0,
        propertiesToAddOrUpdate: {
          "name": "test2",
        },
      );

      expect(true, modifiedNode?.properties["name"] != node?.properties["name"]);
      expect("test2", modifiedNode?.properties["name"]);
      expect(
        () => client2.updateNodeById(nodeId: 0, propertiesToAddOrUpdate: {}),
        throwsException,
      );
      expect(
        () => client2.updateNodeById(nodeId: -1, propertiesToAddOrUpdate: {
          "d":"t"
        }),
        throwsException,
      );
    });
  });

  group('testUpdateRelById', () {
    late NeoClient neoClient2;
    late Relationship? relationship;
    late Relationship? modifiedRelationship;

    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/updateRelById.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceTestUpdateRelationshipById', () async {
      relationship = await neoClient.findRelationshipById(0);

      final client200_2 = MockClient((request) async {
        final responseBody = File('test/json/updateRelById_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient2 = NeoClient.withHttpClient(httpClient: client200_2);

      modifiedRelationship = await neoClient2.updateRelationshipById(
        relationshipId: 0,
        propertiesToAddOrUpdate: {
          "name": "rel2",
        },
      );

      expect(true, modifiedRelationship?.properties["name"] != relationship?.properties["name"]);
      expect("rel2", modifiedRelationship?.properties["name"]);
      expect(
        () => neoClient2.updateRelationshipById(
          relationshipId: -1,
          propertiesToAddOrUpdate: {
            "name": "rel2",
          },
        ),
        throwsException,
      );
      expect(
        () => neoClient2.updateRelationshipById(
          relationshipId: 0,
          propertiesToAddOrUpdate: {},
        ),
        throwsException,
      );
    });
  });

  group('testDeleteAllNodes', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/deleteAllNodes_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceDeleteAllNodes', () async {
      await neoClient.deleteAllNode();
      final result = await neoClient.findAllNodes();
      expect(true, result.isEmpty);
    });
  });

  group('testDeleteNodeById', () {
    late NeoClient neoClient2;

    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/deleteNodeById.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceDeleteNodeById', () async {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/deleteNodeById_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient2 = NeoClient.withHttpClient(httpClient: client200);

      await neoClient.deleteNodeById(7);
      final nodes2 = await neoClient2.findAllNodes();
      expect(1, nodes2.length);
      expect(() => neoClient.deleteNodeById(-1), throwsException);
    });
  });

  group('testCreateNodeWIthNode', () {
    late NeoClient neoClient2;

    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/createNodeWithNode.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceIsRelationshipExistsBetweenTwoNodes', () async {
      await neoClient.createNodeWithNode(Node.withoutId(
        properties: {
          "num": 1,
          "name": "test1",
        },
        labels: ["Node"],
      ));

      final client200 = MockClient((request) async {
        final responseBody = File('test/json/createNodeWithNode_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient2 = NeoClient.withHttpClient(httpClient: client200);

      final nodes2 = await neoClient2.findAllNodes();
      expect(10, nodes2.first.id);
      expect(true, nodes2.isNotEmpty);
      expect("test1", nodes2.first.properties["name"]);
      expect(() => neoClient.createNodeWithNode(Node.withoutId(properties: {}, labels: ["a"])), throwsException);
      expect(() => neoClient.createNodeWithNode(Node.withoutId(properties: {"t": "t"}, labels: [])), throwsException);
    });
  });

  group('testCreateRelationshipFromNodeToNodes', () {
    late NeoClient neoClient2;

    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/createRelFromNodeToNodes.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceIsRelationshipExistsBetweenTwoNodes', () async {
      await neoClient.createRelationshipFromNodeToNodes(
        startNodeId: 49,
        endNodesId: [50, 51],
        relationName: "IS_FRIEND_OF",
        properties: {
          "duree": 1,
          "test": 1,
        },
      );

      final client200 = MockClient((request) async {
        final responseBody = File('test/json/createRelFromNodeToNodes_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient2 = NeoClient.withHttpClient(httpClient: client200);

      final result2 = await neoClient2.findAllRelationship();
      expect(true, result2.isNotEmpty);
      expect(49, result2.first.startNode.id!);
      expect(51, result2.first.endNode.id!);
      expect(49, result2.last.startNode.id!);
      expect(50, result2.last.endNode.id!);
      expect(
        () => neoClient.createRelationshipFromNodeToNodes(
          startNodeId: 49,
          endNodesId: [50],
          relationName: "IS_FRIEND_OF",
          properties: {
            "duree": 1,
            "test": 1,
          },
        ),
        throwsException,
      );
      expect(
        () => neoClient.createRelationshipFromNodeToNodes(
          startNodeId: 49,
          endNodesId: [],
          relationName: "IS_FRIEND_OF",
          properties: {
            "duree": 1,
            "test": 1,
          },
        ),
        throwsException,
      );
      expect(
        () => neoClient.createRelationshipFromNodeToNodes(
          startNodeId: -49,
          endNodesId: [12,42],
          relationName: "IS_FRIEND_OF",
          properties: {
            "duree": 1,
            "test": 1,
          },
        ),
        throwsException,
      );
      expect(
        () => neoClient.createRelationshipFromNodeToNodes(
          startNodeId: 49,
          endNodesId: [-12,42],
          relationName: "IS_FRIEND_OF",
          properties: {
            "duree": 1,
            "test": 1,
          },
        ),
        throwsException,
      );
    });
  });

  group('testCreateRelationship', () {
    late NeoClient neoClient2;

    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/createRelationship.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('testNeoServiceIsRelationshipExistsBetweenTwoNodes', () async {
      await neoClient.createRelationship(
        startNodeId: 54,
        endNodeId: 55,
        relationshipLabel: "TEST",
        properties: {
          "test": "t1",
        },
      );

      final client200 = MockClient((request) async {
        final responseBody = File('test/json/createRelationship_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });
      neoClient2 = NeoClient.withHttpClient(httpClient: client200);

      final result2 = await neoClient2.findAllRelationship();

      expect(true, result2.isNotEmpty);
      expect(54, result2.first.startNode.id!);
      expect(55, result2.first.endNode.id!);
    });
  });

  test('testStringUtil', () {
    expect("test,test2,test3", StringUtil.buildLabelString(["test", "test2", "test3"]));
  });

}
