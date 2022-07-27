library neo4dart.neo4dart_test;

import 'dart:io';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:neo4dart/src/exception/no_param_node_exception.dart';
import 'package:neo4dart/src/model/property_to_check.dart';
import 'package:neo4dart/src/neo4dart/neo_client.dart';
import 'package:test/test.dart';

void main() {
  late NeoClient neoClient;

  group('testFindByProperties', () {
    setUp(() {
      final client200 = MockClient((request) async {
        final responseBody = File('test/json/findNodesByProperties_OK.json').readAsStringSync();
        return Response(responseBody, 200);
      });

      neoClient = NeoClient.withHttpClient(httpClient: client200);
    });

    test('test', () async {
      final test = await neoClient.findAllNodesByProperties(propertiesToCheck: [
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
      ]);

      expect(true, test.isNotEmpty);
    });
  });

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
        relationName: "TEST_NUMBER_2",
        properties: {
          "name": "TEST_2",
          "test": 2,
        },
      );
      expect(12, result?.startNode.id);
      expect(14, result?.endNode.id);
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

      expect(true, firstNode?.label.contains(label));
      expect(name, firstNode?.properties['name']);
      expect(surname, firstNode?.properties['prenom']);
      expect(age, firstNode?.properties['age']);

      expect(
        neoClient.createNode(labels: [label], properties: {}),
        throwsA(const TypeMatcher<NoParamNodeException>()),
      );
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

      expect(true, nodes?.label.contains("Person1"));
      expect("Clement2", nodes?.properties["prenom"]);
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
      expect("Clement1", nodes?.first.properties["prenom"]);
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
}
